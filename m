Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3BA86B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 21:32:00 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ts6so375929729pac.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:32:00 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id p128si1238725pfb.108.2016.07.04.18.32.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 18:32:00 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id ib6so929189pad.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:32:00 -0700 (PDT)
Date: Tue, 5 Jul 2016 10:32:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 3/8] mm/zsmalloc: take obj index back from
 find_alloced_obj
Message-ID: <20160705013204.GF459@swordfish>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-3-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467614999-4326-3-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On (07/04/16 14:49), Ganesh Mahendran wrote:
> the obj index value should be updated after return from
> find_alloced_obj() to avoid CPU buring caused by unnecessary
> object scanning.

'burning'

> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
