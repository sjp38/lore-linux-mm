From: Erich Focht <efocht@hpce.nec.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Date: Mon, 8 Nov 2004 18:26:16 +0100
References: <4189EC67.40601@yahoo.com.au> <200411081730.37906.efocht@hpce.nec.com> <20041108175710.72e76064.diegocg@teleline.es>
In-Reply-To: <20041108175710.72e76064.diegocg@teleline.es>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8BIT
Message-Id: <200411081826.16550.efocht@hpce.nec.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Diego Calleja <diegocg@teleline.es>
Cc: clameter@sgi.com, mbligh@aracnet.com, nickpiggin@yahoo.com.au, benh@kernel.crashing.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 08 November 2004 17:57, Diego Calleja wrote:
> El Mon, 8 Nov 2004 17:30:37 +0100 Erich Focht <efocht@hpce.nec.com> escribio:
> 
> > You're talking about clusters, i.e. multiple running instances of the
> > operating system. I don't think anybody really wants to go far beyond
> > 512 nowadays. Application-wise 512 cpus/node isn't really needed (but
> 
> <the newspaper guy>
> 
> SGI is already building one of 1024 CPUs according to some sources:
> http://www.computerworld.com/hardwaretopics/hardware/story/0,10801,94564,00.html
> 
> but...
> 
> "Initially, Pennington said, the system will use two images of Linux -- one
> per 512 processors -- while it's being tested and configured. Later, all 1,024
> processors will address one image of the SGI Advanced Linux operating system
> being used."

1k is not really "far beyond" 512. I'm sure it's doable, but I doubt
that this (or bigger machines) will spread too much. The progress in
cluster interconnect technology and software is just too fast. Think
of price/performance and stability (MTBF accumulation) and judge
yourself. Sure, if Linux could survive breaking hardware, the story
might change.

> Also here ->
> http://www.sgi.com/company_info/newsroom/press_releases/2004/november/jaeri.html
> it talks about another supercomputer of 2048 CPUs, but I don't find clear
> if it's a cluster, or several images. 

That was advertised to be a fraction of the Columbia machine, so a
cluster of big machines.

Erich

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
