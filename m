Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 53FB5600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:29:02 -0500 (EST)
Date: Wed, 2 Dec 2009 21:28:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 06/24] HWPOISON: abort on failed unmap
Message-ID: <20091202132819.GC13277@localhost>
References: <20091202031231.735876003@intel.com> <20091202043044.293905787@intel.com> <20091202131150.GE18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202131150.GE18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 09:11:50PM +0800, Andi Kleen wrote:
> >  	 * Now take care of user space mappings.
> > +	 * Abort on fail: __remove_from_page_cache() assumes unmapped page.
> >  	 */
> > -	hwpoison_user_mappings(p, pfn, trapno);
> > +	if (hwpoison_user_mappings(p, pfn, trapno) != SWAP_SUCCESS) {
> > +		res = -EBUSY;
> > +		goto out;
> 
> It would be good to print something in this case.

OK.

> Did you actually see it during testing?

Perhaps not.

> Or maybe loop forever in the unmapper.

!SWAP_SUCCESS should be rare, so not necessary to loop forever?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
