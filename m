Date: Tue, 30 Nov 2004 09:11:24 -0800
From: cliff white <cliffw@osdl.org>
Subject: Re: Automated performance testing system was Re: Text form for STP
 tests
Message-Id: <20041130091124.45ef483c.cliffw@osdl.org>
In-Reply-To: <127280000.1101834058@[10.10.2.4]>
References: <20041125093135.GA15650@logos.cnet>
	<200411282017.iASKH2F05015@mail.osdl.org>
	<20041130004212.GB2310@dmt.cyclades>
	<127280000.1101834058@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2004 09:00:59 -0800
"Martin J. Bligh" <mbligh@aracnet.com> wrote:

> > I've been talking to Cliff about the need for a set of benchmarks,
> > covering as many different workloads as possible, for developers to have a 
> > better notion of impact on performance changes. 
> > 
> > Usually when one does a change which affects performance, he/she runs one 
> > or two benchmarks with a limited amount of hardware configurations.
> > This is a very painful, boring and time consuming process, which can 
> > result in misinterpretation and/or limited understading of the results 
> > of such changes.
> > 
> > It is important to automate such process, with a set of benchmarks 
> > covering as wide as possible range of workloads, running on common 
> > and most used hardware variations.
> > 
> > OSDL's STP provides the base framework for this.
> > 
> > Cliff mentioned an internal tool they are developing for this purpose, 
> > based on XML-like configuration files. 
> > 
> > I have suggested him a set of benchmarks (available on STP right now, 
> > we want to add other benchmarks there whenever necessary) and a set of 
> > CPU/memory variations.
> 
> Sounds like a good plan in general, by why on earth would you want to do
> it in XML? Personally I'm not that much into masochism. A simple text
> control file is perfectly sufficient (and yes, we do this internally).

True, very true. What i was showing Marcelo was what we do internally, which
was not desiged for humans. What we're working on currently _is designed for humans,
and not XML.

I'm making up this AM a control file for STP for the tests marcelo requested, and
we won't be asking humans to do XML, no. 

Martin, if you could share any of your internal goop ( and save me work ) it would be 
great. If you all have a text format that large numbers of people find sensible, i'd love it.
So far, it's just been me and the robots. 

( btw, it's XML because XML::Simple just seemed so....simple. I was young then. ) 
cliffw

> 
> M.
> 


-- 
The church is near, but the road is icy.
The bar is far, but i will walk carefully. - Russian proverb
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
