Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 36A536B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 20:40:07 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u186so73854649ita.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 17:40:07 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id n194si281669iod.64.2016.07.19.17.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 17:40:06 -0700 (PDT)
Date: Tue, 19 Jul 2016 19:40:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -next] mm/slab: use list_move instead of
 list_del/list_add
In-Reply-To: <1468929772-9174-1-git-send-email-weiyj_lk@163.com>
Message-ID: <alpine.DEB.2.20.1607191939430.29303@east.gentwo.org>
References: <1468929772-9174-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yongjun <weiyj_lk@163.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
