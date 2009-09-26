Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 877306B0055
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 15:14:51 -0400 (EDT)
Date: Sat, 26 Sep 2009 21:14:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090926191454.GD14368@wotan.suse.de>
References: <20090926031537.GA10176@localhost> <Pine.LNX.4.64.0909261115530.12927@sister.anvils> <20090926114806.GA12419@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090926114806.GA12419@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Sep 26, 2009 at 07:48:06PM +0800, Wu Fengguang wrote:
> On Sat, Sep 26, 2009 at 07:09:21PM +0800, Hugh Dickins wrote:
> > It seems to me that the Intel hardware guys have done half a job
> > here: the sooner they get to remapping the bad pages, the better.
> 
> When we can offer to set aside half memory :)

Maybe even adding to the ECC error codes so uncorrected errors
are reduced to a similar frequency to other sources of errors in
the hardware. That seems like the sanest thing to me, but it's
not mine to wonder...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
