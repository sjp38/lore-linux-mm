Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2927B6B006E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 20:03:00 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so24715103pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:02:59 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id fn2si10911136pac.163.2015.06.09.17.02.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 17:02:59 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so24714942pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:02:59 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:03:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: fix a null pointer dereference in
 destroy_handle_cache()
Message-ID: <20150610000303.GA13376@bgram>
References: <1433502690-2524-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433502690-2524-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri, Jun 05, 2015 at 08:11:30PM +0900, Sergey Senozhatsky wrote:
> zs_destroy_pool()->destroy_handle_cache() invoked from
> zs_create_pool() can pass a NULL ->handle_cachep pointer
> to kmem_cache_destroy(), which will dereference it.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Thanks, Sergey!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
