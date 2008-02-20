Date: Wed, 20 Feb 2008 11:48:41 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <20080219210739.27325078@bree.surriel.com>
References: <20080219222828.GB28786@elf.ucw.cz> <20080219210739.27325078@bree.surriel.com>
Message-Id: <20080220114317.642F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Pavel Machek <pavel@ucw.cz>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

Hi Rik

> > Sounds like a job for memory limits (ulimit?), not for OOM
> > notification, right?
> 
> I suspect one problem could be that an HPC job scheduling program
> does not know exactly how much memory each job can take, so it can
> sometimes end up making a mistake and overcommitting the memory on
> one HPC node.
> 
> In that case the user is better off having that job killed and
> restarted elsewhere, than having all of the jobs on that node
> crawl to a halt due to swapping.
> 
> Paul, is this guess correct? :)

Yes.
Fujitsu HPC middleware watching sum of memory consumption of the job
and, if over-consumption happened, kill process and remove job schedule.

I think that is common hpc requirement.
but we watching to user defined memory limit, not swap.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
