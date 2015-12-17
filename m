Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 34DAD4402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 11:08:48 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id m11so15786633igk.1
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 08:08:48 -0800 (PST)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id q16si4552413igr.96.2015.12.17.08.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 08:08:46 -0800 (PST)
Received: by mail-io0-x236.google.com with SMTP id e126so59863071ioa.1
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 08:08:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1442222687-9758-2-git-send-email-schwidefsky@de.ibm.com>
References: <1442222687-9758-1-git-send-email-schwidefsky@de.ibm.com>
	<1442222687-9758-2-git-send-email-schwidefsky@de.ibm.com>
Date: Thu, 17 Dec 2015 19:08:46 +0300
Message-ID: <CAM5jBj5vOTjbt1f3Z6P=qQymX5-_W6bLGVQ1Q9FERx6tpKbthQ@mail.gmail.com>
Subject: Re: [PATCH] mm/swapfile: mm/swapfile: fix swapoff vs. software dirty bits
From: Cyrill Gorcunov <gorcunov@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Sep 14, 2015 at 12:24 PM, Martin Schwidefsky
<schwidefsky@de.ibm.com> wrote:
> Fixes a regression introduced with commit 179ef71cbc085252
> "mm: save soft-dirty bits on swapped pages"
>
> The maybe_same_pte() function is used to match a swap pte independent
> of the swap software dirty bit set with pte_swp_mksoft_dirty().
>
> For CONFIG_HAVE_ARCH_SOFT_DIRTY=y but CONFIG_MEM_SOFT_DIRTY=n the
> software dirty bit may be set but maybe_same_pte() will not recognize
> a software dirty swap pte. Due to this a 'swapoff -a' will hang.
>
> The straightforward solution is to replace CONFIG_MEM_SOFT_DIRTY
> with HAVE_ARCH_SOFT_DIRTY in maybe_same_pte().
>
> Cc: linux-mm@kvack.org
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

We've been discussing this already
http://comments.gmane.org/gmane.linux.kernel.mm/138664

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
