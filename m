Date: Tue, 30 Nov 2004 09:00:59 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Automated performance testing system was Re: Text form for STP tests
Message-ID: <127280000.1101834058@[10.10.2.4]>
In-Reply-To: <20041130004212.GB2310@dmt.cyclades>
References: <20041125093135.GA15650@logos.cnet> <200411282017.iASKH2F05015@mail.osdl.org> <20041130004212.GB2310@dmt.cyclades>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Cliff White <cliffw@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I've been talking to Cliff about the need for a set of benchmarks,
> covering as many different workloads as possible, for developers to have a 
> better notion of impact on performance changes. 
> 
> Usually when one does a change which affects performance, he/she runs one 
> or two benchmarks with a limited amount of hardware configurations.
> This is a very painful, boring and time consuming process, which can 
> result in misinterpretation and/or limited understading of the results 
> of such changes.
> 
> It is important to automate such process, with a set of benchmarks 
> covering as wide as possible range of workloads, running on common 
> and most used hardware variations.
> 
> OSDL's STP provides the base framework for this.
> 
> Cliff mentioned an internal tool they are developing for this purpose, 
> based on XML-like configuration files. 
> 
> I have suggested him a set of benchmarks (available on STP right now, 
> we want to add other benchmarks there whenever necessary) and a set of 
> CPU/memory variations.

Sounds like a good plan in general, by why on earth would you want to do
it in XML? Personally I'm not that much into masochism. A simple text
control file is perfectly sufficient (and yes, we do this internally).

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
