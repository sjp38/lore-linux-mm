Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l1MHLYn9002553
	for <linux-mm@kvack.org>; Thu, 22 Feb 2007 09:21:34 -0800
Received: from mu-out-0910.google.com (muew9.prod.google.com [10.102.174.9])
	by zps77.corp.google.com with ESMTP id l1MHKvbh031557
	for <linux-mm@kvack.org>; Thu, 22 Feb 2007 09:21:30 -0800
Received: by mu-out-0910.google.com with SMTP id w9so196420mue
        for <linux-mm@kvack.org>; Thu, 22 Feb 2007 09:21:30 -0800 (PST)
Message-ID: <6599ad830702220921w71126a5bg2a21a08befce7bec@mail.gmail.com>
Date: Thu, 22 Feb 2007 09:21:29 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Take anonymous pages off the LRU if we have no swap
In-Reply-To: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/21/07, Christoph Lameter <clameter@sgi.com> wrote:
> If the kernel was compiled without support for swapping then we have no means
> of evicting anonymous pages and they become like mlocked pages.

How will this interact with page migration?

In order to start migrating a page, the migration paths call
isolate_lru_page(), which returns -EBUSY if the page isn't on an LRU.

At a minimum, CONFIG_MIGRATION should either select or depend on CONFIG_SWAP.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
