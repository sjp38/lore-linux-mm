Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 49BB16B0002
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 20:23:59 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id CBA9312AF92
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 01:23:57 +0100 (CET)
Date: Wed, 27 Mar 2013 01:23:57 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH] staging: zsmalloc: Fix link error on ARM
Message-ID: <20130327002357.GG30540@8bytes.org>
References: <1364337232-3513-1-git-send-email-joro@8bytes.org>
 <20130327000552.GA13283@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130327000552.GA13283@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@lge.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 27, 2013 at 09:05:52AM +0900, Minchan Kim wrote:
> Oops, it was my fault. When I tested [1] on CONFIG_SMP machine on ARM,
> it worked well. It means it's not always problem on every CONFIG_SMP
> on ARM machine but some SMP machine define flush_tlb_kernel_range,
> others don't.
> 
> At that time, Russell King already suggested same thing with your patch
> and I meant to clean it up because the patch was already merged but I didn't.
> Because we didn't catch up that it breaks build on some configuration
> so I thought it's just clean up patch and Greg didn't want to accept
> NOT-BUG patch of any z* family.
> 
> Now, it's BUG patch.
> 
> Remained problem is that Greg doesn't want to export core function for
> staging driver and it's reasonable for me.

Okay, I see. So that is probably also the reason for the
reimplementation of unmap_kernel_range in the zsmalloc module :)

> So my opinion is remove zsmalloc module build and could recover it with
> making unmap_kernel_range exported function after we merged it into
> mainline.

Sounds reasonable, I update the patch to only allow zsmalloc to be
built-in. The benefit is that this still allows to use
unmap_kernel_range() in the driver.

Thanks,

	Joerg


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
