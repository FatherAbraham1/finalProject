package edu.uchicago.mpcs53013.finalProject;

import java.io.Serializable;
import java.util.Date;

import com.google.common.base.Objects;

import edu.uchicago.mpcs53013.source_new.Source_new;

public class CassandraSource implements Serializable {
	private long number;
	private double time;
	private String source;

	private String destination;
	private String protocol;
	private String info;
	private long length;

	public CassandraSource() {}
	
	CassandraSource(Source_new source_new) {
		this.number= source_new.number;
		this.time=source_new.time;
		this.source=source_new.source;
		this.destination=source_new.destination;
		this.protocol=source_new.protocol;
		this.info=source_new.info;
		this.length=source_new.length;
	}

	public long getNumber() {
		return number;
	}

	public void setNumber(Integer number) {
		this.number = number;
	}

	public Double getTime() {
		return time;
	}

	public void setTime(Double time) {
		this.time = time;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getDestination() {
		return destination;
	}

	public void setDestination(String Destination) {
		this.destination=destination;
	}

	public String getProtocol() {
		return protocol;
	}

	public void setProtocol(String protocol) {
		this.protocol=protocol;
	}

	public String getInfo() {
		return info;
	}

	public void setInfo(String Info) {
		this.info=info;
	}

	public long getLength() {
		return length;
	}

	public void setLength(int length) {
		this.length=length;
	}


	@Override
	public String toString() {
		return Objects.toStringHelper(this)
				.add("number", number)
				.add("time", time)
				.add("source", source)
				.add("destination", destination)
				.add("protocol", protocol)
				.add("info", info)
				.add("length",length)
				.toString();
	}

}
