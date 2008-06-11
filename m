From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.26-rc5-mm2: OOM with 1G free swap
Date: Wed, 11 Jun 2008 16:31:13 +1000
References: <20080609223145.5c9a2878.akpm@linux-foundation.org> <20080611060029.GA5011@martell.zuzino.mipt.ru> <20080610232705.3aaf5c06.akpm@linux-foundation.org>
In-Reply-To: <20080610232705.3aaf5c06.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806111631.13920.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 11 June 2008 16:27, Andrew Morton wrote:
> On Wed, 11 Jun 2008 10:00:29 +0400 Alexey Dobriyan <adobriyan@gmail.com> 
wrote:
> > On Mon, Jun 09, 2008 at 10:31:45PM -0700, Andrew Morton wrote:
> > > - This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
> > >   vmscan.c bug which would have prevented testing of the other vmscan.c
> > >   bugs^Wchanges.
> >
> > OOM condition happened with 1G free swap.
>
> Thanks for testing.  Again.
>
> > 4G RAM, 1G swap partition, normally LTP survives during much, much higher
> > load.
> >
> > vm.overcommit_memory = 0
> > vm.overcommit_ratio = 50
>
> Well I assume that Rik ran LTP.  Perhaps a merge problem.
>
> > ...
> >
> > [ 6773.608125] init invoked oom-killer: gfp_mask=0x1201d2, order=0,
> > oomkilladj=0
>
> GFP_USER
>
> > [ 6773.608215] Pid: 1, comm: init Not tainted 2.6.26-rc5-mm2 #2
>
> wot?  The oom-killer isn't supposed to kill init!

It is init that invokes the OOM killer, the actual process killed
comes at the end I believe:

 [...]

> > [ 6773.631799] Out of memory: kill process 4788 (sshd) score 11194 or a
> > child [ 6773.631876] Killed process 4789 (bash)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
