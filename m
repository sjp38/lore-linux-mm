Subject: Re: NUMA is bust with CONFIG_PREEMPT=y
From: Robert Love <rml@tech9.net>
In-Reply-To: <389320000.1033596266@flay>
References: <3D9B6939.397DB9EA@digeo.com>  <384860000.1033595383@flay>
	 <1033596139.27343.14.camel@phantasy>  <389320000.1033596266@flay>
Content-Type: text/plain
Message-Id: <1033596906.27765.39.camel@phantasy>
Mime-Version: 1.0
Date: 02 Oct 2002 18:15:07 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2002-10-02 at 18:04, Martin J. Bligh wrote:

> > I am not one of the 12 people in the world with a NUMA-Q, but I would
> > not like to see you disable kernel preemption.
> 
> What does it buy you on a large NUMA box over the low-latency patches?

Latency-wise?  Probably very little.  But note Andrew is not going to
maintain the low-latency patches through 2.6/3.0 as far as I know.

The reasons I asked for you to keep it were mainly (a) so everything can
support it, and (b) for the useful atomicity/sleeping debugging checks.

And when I get consumer-level NUMA x86-64 in hopefully a few years I
need kernel preemption to work :)

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
