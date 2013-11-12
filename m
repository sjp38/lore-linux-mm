Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E64C26B0101
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 19:13:58 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so1833266pad.38
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 16:13:58 -0800 (PST)
Received: from psmtp.com ([74.125.245.116])
        by mx.google.com with SMTP id ao1si748676pad.90.2013.11.11.16.13.55
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 16:13:56 -0800 (PST)
Date: Tue, 12 Nov 2013 00:13:15 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 0/4] Intermix Lowmem and vmalloc
Message-ID: <20131112001315.GD16735@n2100.arm.linux.org.uk>
References: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Mon, Nov 11, 2013 at 03:26:48PM -0800, Laura Abbott wrote:
> Hi,
> 
> This is an RFC for a feature to allow lowmem and vmalloc virtual address space
> to be intermixed. This has currently only been tested on a narrow set of ARM
> chips.
> 
> Currently on 32-bit systems we have
> 
> 
>                   Virtual                             Physical
> 
>    PAGE_OFFSET   +--------------+     PHYS_OFFSET   +------------+
>                  |              |                   |            |
>                  |              |                   |            |
>                  |              |                   |            |
>                  | lowmem       |                   |  direct    |
>                  |              |                   |   mapped   |
>                  |              |                   |            |
>                  |              |                   |            |
>                  |              |                   |            |
>                  +--------------+------------------>x------------>
>                  |              |                   |            |
>                  |              |                   |            |
>                  |              |                   |  not-direct|
>                  |              |                   | mapped     |
>                  | vmalloc      |                   |            |
>                  |              |                   |            |
>                  |              |                   |            |
>                  |              |                   |            |
>                  +--------------+                   +------------+
> 
> Where part of the virtual spaced above PHYS_OFFSET is reserved for direct
> mapped lowmem and part of the virtual address space is reserved for vmalloc.

Minor nit...

ITYM PAGE_OFFSET here.  vmalloc space doesn't exist in physical memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
