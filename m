Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8A226B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:07:13 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n85so57476305pfi.4
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:07:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z6si27802031pan.160.2016.11.07.15.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:07:13 -0800 (PST)
Date: Mon, 7 Nov 2016 15:07:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/2] mm: Check kmem_create_cache flags are commons
Message-Id: <20161107150712.d7b26fc6cf6c403b85f9e36a@linux-foundation.org>
In-Reply-To: <1478553075-120242-2-git-send-email-thgarnie@google.com>
References: <1478553075-120242-1-git-send-email-thgarnie@google.com>
	<1478553075-120242-2-git-send-email-thgarnie@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, vdavydov.dev@gmail.com, mhocko@kernel.org

On Mon,  7 Nov 2016 13:11:15 -0800 Thomas Garnier <thgarnie@google.com> wrote:

> Verify that kmem_create_cache flags are not allocator specific. It is
> done before removing flags that are not available with the current
> configuration.

What is the reason for this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
