Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4996B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:08:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p64so54445643pfb.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 12:08:32 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id j10si34056142pax.283.2016.07.19.12.08.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 12:08:31 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id pp5so9653154pac.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 12:08:31 -0700 (PDT)
Date: Tue, 19 Jul 2016 12:08:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -next] mm/slab: use list_move instead of
 list_del/list_add
In-Reply-To: <1468929772-9174-1-git-send-email-weiyj_lk@163.com>
Message-ID: <alpine.DEB.2.10.1607191207560.52203@chino.kir.corp.google.com>
References: <1468929772-9174-1-git-send-email-weiyj_lk@163.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yongjun <weiyj_lk@163.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 19 Jul 2016, Wei Yongjun wrote:

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using list_move() instead of list_del() + list_add().
> 

... to prevent needlessly poisoning the next and prev values.

> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
