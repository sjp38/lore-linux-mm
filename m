Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14FD26B026A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 21:15:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 143so164263602pfx.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 18:15:30 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id qo11si20837367pab.106.2016.06.13.18.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 18:15:29 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id c2so51486767pfa.2
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 18:15:29 -0700 (PDT)
Date: Tue, 14 Jun 2016 10:15:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: keep first object offset in struct page
Message-ID: <20160614011528.GA387@swordfish>
References: <1465788015-23195-1-git-send-email-minchan@kernel.org>
 <20160613033718.GA23754@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160613033718.GA23754@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/13/16 12:37), Minchan Kim wrote:
> 
> Please fold it to zsmalloc: page migration support.

I like the change and the removal of get_first_obj_offset().
thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
