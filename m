Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD5E8E00BD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 01:21:58 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n39so9513089qtn.18
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 22:21:58 -0800 (PST)
Received: from wnew1-smtp.messagingengine.com (wnew1-smtp.messagingengine.com. [64.147.123.26])
        by mx.google.com with ESMTPS id m25si13499972qtg.282.2019.01.24.22.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 22:21:57 -0800 (PST)
Date: Fri, 25 Jan 2019 07:21:51 +0100
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] mm: proc: smaps_rollup: Fix pss_locked calculation
Message-ID: <20190125062151.GA19629@kroah.com>
References: <20190121011049.160505-1-sspatil@android.com>
 <20190123225746.5B3DF218A4@mail.kernel.org>
 <20190124213940.GG243073@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124213940.GG243073@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sandeep Patil <sspatil@android.com>
Cc: Sasha Levin <sashal@kernel.org>, vbabka@suse.cz, adobriyan@gmail.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Thu, Jan 24, 2019 at 01:39:40PM -0800, Sandeep Patil wrote:
> On Wed, Jan 23, 2019 at 10:57:45PM +0000, Sasha Levin wrote:
> > Hi,
> > 
> > [This is an automated email]
> > 
> > This commit has been processed because it contains a "Fixes:" tag,
> > fixing commit: 493b0e9d945f mm: add /proc/pid/smaps_rollup.
> > 
> > The bot has tested the following trees: v4.20.3, v4.19.16, v4.14.94.
> > 
> > v4.20.3: Build OK!
> > v4.19.16: Build OK!
> > v4.14.94: Failed to apply! Possible dependencies:
> >     8526d84f8171 ("fs/proc/task_mmu.c: do not show VmExe bigger than total executable virtual memory")
> >     8e68d689afe3 ("mm: /proc/pid/smaps: factor out mem stats gathering")
> >     af5b0f6a09e4 ("mm: consolidate page table accounting")
> >     b4e98d9ac775 ("mm: account pud page tables")
> >     c4812909f5d5 ("mm: introduce wrappers to access mm->nr_ptes")
> >     d1be35cb6f96 ("proc: add seq_put_decimal_ull_width to speed up /proc/pid/smaps")
> > 
> > 
> > How should we proceed with this patch?
> 
> I will send 4.14 / 4.9 backports to -stable if / when the patch gets
> accepted.

That's fine, you will get the automated "FAILED:" emails when I try to
apply it to the tree at that time, and you can send an updated version
then if you want.

thanks,

greg k-h
