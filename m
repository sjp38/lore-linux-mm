Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 48CDA6B0254
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:08:46 -0500 (EST)
Received: by padhx2 with SMTP id hx2so18086349pad.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 02:08:46 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ey1si25515157pab.184.2015.11.24.02.08.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 02:08:45 -0800 (PST)
Received: by padhx2 with SMTP id hx2so18086119pad.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 02:08:45 -0800 (PST)
Date: Tue, 24 Nov 2015 19:09:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH -mm v2] mm: add page_check_address_transhuge helper
Message-ID: <20151124100944.GA514@swordfish>
References: <1448011913-12121-1-git-send-email-vdavydov@virtuozzo.com>
 <20151124042941.GE705@swordfish>
 <20151124090930.GB15712@node.shutemov.name>
 <20151124093617.GE29014@esperanza>
 <20151124094659.GF29014@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124094659.GF29014@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On (11/24/15 12:46), Vladimir Davydov wrote:
> 
> Sergey, could you please check if the patch below fixes build for you?

yes, it does.

add/remove: 0/1 grow/shrink: 0/2 up/down: 0/-649 (-649)
function                                     old     new   delta
__warned                                    2632    2631      -1
page_referenced_one                          218     159     -59
page_check_address_transhuge                 589       -    -589

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
