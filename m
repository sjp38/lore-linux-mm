Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E03876B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 10:41:03 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j4so2340293wrg.15
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 07:41:03 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m3si140084wmc.18.2017.12.06.07.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 07:41:02 -0800 (PST)
Date: Wed, 6 Dec 2017 16:41:02 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm: Export unmapped_area*() functions
Message-ID: <20171206154102.GA26419@lst.de>
References: <1512486927-32349-1-git-send-email-hareeshg@codeaurora.org> <20171205152944.GA10573@lst.de> <d5c9b199-7379-f6e1-d5a4-f072d7f9cd93@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d5c9b199-7379-f6e1-d5a4-f072d7f9cd93@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hareesh Gundu <hareeshg@codeaurora.org>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, jcrouse@codeaurora.org

On Wed, Dec 06, 2017 at 09:00:57PM +0530, Hareesh Gundu wrote:
> On 12/5/2017 8:59 PM, Christoph Hellwig wrote:
>> On Tue, Dec 05, 2017 at 08:45:27PM +0530, Hareesh Gundu wrote:
>>> Add EXPORT_SYMBOL to unmapped_area()
>>> and unmapped_area_topdown(). So they
>>> are usable from modules.
> This change is not for in-tree kernel module. It's for modules built 
> outside of kernel tree modules.

Please prepare the modules for kernel inclusion first, and then we
can understand what you are doing and propose the right solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
