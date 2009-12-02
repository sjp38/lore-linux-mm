Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9F293600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:31:46 -0500 (EST)
Date: Wed, 2 Dec 2009 21:31:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 12/24] HWPOISON: make it possible to unpoison pages
Message-ID: <20091202133126.GE13277@localhost>
References: <20091202031231.735876003@intel.com> <20091202043045.150526892@intel.com> <20091202131530.GG18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202131530.GG18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 09:15:30PM +0800, Andi Kleen wrote:
> > Note that it may leak pages silently - those who have been removed from
> > LRU cache, but not isolated from page cache/swap cache at hwpoison time.
> 
> It would be better if we could detect that somehow and at least warn.
> 
> >  }
> >  
> > +static int hwpoison_forget(void *data, u64 val)
> > +{
> > +	if (!capable(CAP_SYS_ADMIN))
> > +		return -EPERM;
> > +
> > +	return forget_memory_failure(val);
> > +}
> > +
> >  DEFINE_SIMPLE_ATTRIBUTE(hwpoison_fops, NULL, hwpoison_inject, "%lli\n");
> > +DEFINE_SIMPLE_ATTRIBUTE(unpoison_fops, NULL, hwpoison_forget, "%lli\n");
> 
> I'll rename it to unpoison, not forget. I think that's a more clear
> name.

OK. Will repost the whole updated patchset.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
