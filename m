Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2D3D6B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 10:29:46 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id g80so301754wrd.17
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 07:29:46 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s2si257138wrs.115.2017.12.05.07.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 07:29:45 -0800 (PST)
Date: Tue, 5 Dec 2017 16:29:44 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm: Export unmapped_area*() functions
Message-ID: <20171205152944.GA10573@lst.de>
References: <1512486927-32349-1-git-send-email-hareeshg@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1512486927-32349-1-git-send-email-hareeshg@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hareesh Gundu <hareeshg@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

On Tue, Dec 05, 2017 at 08:45:27PM +0530, Hareesh Gundu wrote:
> Add EXPORT_SYMBOL to unmapped_area()
> and unmapped_area_topdown(). So they
> are usable from modules.

Please send this along with the actual modules.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
