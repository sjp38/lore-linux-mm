Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CE2B96B0044
	for <linux-mm@kvack.org>; Sun, 25 Jan 2009 16:39:22 -0500 (EST)
Received: by ewy8 with SMTP id 8so1088354ewy.14
        for <linux-mm@kvack.org>; Sun, 25 Jan 2009 13:39:21 -0800 (PST)
Message-ID: <497CDC06.3030900@gmail.com>
Date: Sun, 25 Jan 2009 22:39:18 +0100
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH -mmotm] mm: unify some pmd_*() functions
References: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
In-Reply-To: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 2009-01-25 22:35, Andrea Righi wrote:
> Unify all the identical implementations of pmd_free(), __pmd_free_tlb(),
> pmd_alloc_one(), pmd_addr_end() in include/asm-generic/pgtable-nopmd.h
> 

BTW, I only tested this on x86 and x86_64. This needs more testing because it
touches also a lot of other architectures.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
