Date: Fri, 24 Dec 2004 12:23:01 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Splitting the page migration patches out of  the memory hotplug patch
Message-ID: <20041224142301.GA7219@logos.cnet>
References: <41CC4517.3080506@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <41CC4517.3080506@sgi.com>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Dave@sr71.net, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 24, 2004 at 10:34:31AM -0600, Ray Bryant wrote:
> (Addling linux-mm, Marcello and Hirakazu....what I'm up
> to is trying to create a roll-up patch that contains just
> the memory migration code from mhp3, since I need page
> migration for some work I am doing.)
> 
> Dave,
> 
> Well, the only other big change I made (other than dropping
> P32-memsection_migrate.patch) to get it to compile and boot
> for Altix were as follows:
> 
> (I'll work on testing it after the holiday.)
> 
> P29-add-memory-migration-to-Kconfig-ia64.patch
> 
>         Add memory migration to the config menu
>         for ia64.
> 
> P30-remove-page_under_capture.patch
> 
>         removed page_under_capture() from the end
>         of shrink_cache() in mm/vmscan.c.  This
>         is not defined in the P series of patches.
>         This particular call was introduced by patch
>         P01-steal_page_from_lru.patch
> 
> (I'm not sure how to number these patches to fit in with
> your scheme, so just made some stuff up.)
> 
> (Oh yeah, this is in top of 2.6.10-rc2-mm4.)
> 
> Now it would be nice if we could figure out a way to keep
> these patchsets distinct (i. e. so work on page migration
> and hotplug can continue without me redoing this every
> week or two.)
> 
> One way to do that would be to fix it so that the page
> migration patches are first in the hotplug patch, or to
> separate the two out and assume that hotplug patch goes
> on top of the page migration patch.  How would you like
> to go about this? (I'll take a whack at moving them to
> the top of the mhp3 series file and see how much trouble
> I get into....)

I think thats up to Dave who maintains the patchset.

> PS:  It doesn't look like Marcello and Hirakazu's
> migration patch is part of your P* series.  Is
> that correct?

Yes, the plan is to merge the migration cache to the memory 
hotplug as soon as its well tested - we still lack transformation of 
migration pages into swap pages, which involves redoing all pte's
of a given migration page. 

Happy holiday!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
