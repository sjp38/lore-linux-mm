Date: Mon, 8 Nov 2004 17:57:10 +0100
From: Diego Calleja <diegocg@teleline.es>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <20041108175710.72e76064.diegocg@teleline.es>
In-Reply-To: <200411081730.37906.efocht@hpce.nec.com>
References: <4189EC67.40601@yahoo.com.au>
	<226170000.1099843883@[10.10.2.4]>
	<Pine.LNX.4.58.0411080800020.7996@schroedinger.engr.sgi.com>
	<200411081730.37906.efocht@hpce.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erich Focht <efocht@hpce.nec.com>
Cc: clameter@sgi.com, mbligh@aracnet.com, nickpiggin@yahoo.com.au, benh@kernel.crashing.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

El Mon, 8 Nov 2004 17:30:37 +0100 Erich Focht <efocht@hpce.nec.com> escribio:

> You're talking about clusters, i.e. multiple running instances of the
> operating system. I don't think anybody really wants to go far beyond
> 512 nowadays. Application-wise 512 cpus/node isn't really needed (but

<the newspaper guy>

SGI is already building one of 1024 CPUs according to some sources:
http://www.computerworld.com/hardwaretopics/hardware/story/0,10801,94564,00.html

but...

"Initially, Pennington said, the system will use two images of Linux -- one
per 512 processors -- while it's being tested and configured. Later, all 1,024
processors will address one image of the SGI Advanced Linux operating system
being used."

Also here ->
http://www.sgi.com/company_info/newsroom/press_releases/2004/november/jaeri.html
it talks about another supercomputer of 2048 CPUs, but I don't find clear
if it's a cluster, or several images. 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
