Date: Tue, 19 Feb 2008 22:57:33 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Message-Id: <20080219225733.37c56eb2.pj@sgi.com>
In-Reply-To: <20080220114317.642F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080219222828.GB28786@elf.ucw.cz>
	<20080219210739.27325078@bree.surriel.com>
	<20080220114317.642F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: riel@redhat.com, pavel@ucw.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

Kosaki-san wrote:
> Yes.
> Fujitsu HPC middleware watching sum of memory consumption of the job
> and, if over-consumption happened, kill process and remove job schedule.

Did those jobs share nodes -- sometimes two or more jobs using the same
nodes?  I am sure SGI has such users too, though such job mixes make
the runtimes of specific jobs less obvious, so customers are more
tolerant of variations and some inefficiencies, as they get hidden in
the mix.

In other words, Rik, both yes and no ;).  Both sorts of HPC loads
exist, sharing nodes and a dedicated set of nodes for each job.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
