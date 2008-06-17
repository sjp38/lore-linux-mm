Date: Tue, 17 Jun 2008 18:14:49 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Bad page] trying to free locked page? (Re: [PATCH][RFC] fix kernel BUG at mm/migrate.c:719! in 2.6.26-rc5-mm3)
In-Reply-To: <20080617180314.2d1b0efa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp> <20080617180314.2d1b0efa.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20080617181110.E2D6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > > I got this bug while migrating pages only a few times
> > > via memory_migrate of cpuset.
> > > 
> > > Unfortunately, even if this patch is applied,
> > > I got bad_page problem after hundreds times of page migration
> > > (I'll report it in another mail).
> > > But I believe something like this patch is needed anyway.
> > > 
> > 
> > I got bad_page after hundreds times of page migration.
> > It seems that a locked page is being freed.
> > 
> Good catch, and I think your investigation in the last e-mail was correct.
> I'd like to dig this...but it seems some kind of big fix is necessary.
> Did this happen under page-migraion by cpuset-task-move test ?

Indeed!

I guess lee's unevictable infrastructure and nick's specurative pagecache
is conflicted.
I'm investigating deeply now.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
