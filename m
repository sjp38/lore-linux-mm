Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id D49A76B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 23:22:45 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id d187so411869556ywe.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 20:22:45 -0800 (PST)
Received: from mail-yb0-x230.google.com (mail-yb0-x230.google.com. [2607:f8b0:4002:c09::230])
        by mx.google.com with ESMTPS id j2si7628382yba.198.2016.11.07.20.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 20:22:44 -0800 (PST)
Received: by mail-yb0-x230.google.com with SMTP id d128so62765313ybh.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 20:22:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161107150712.d7b26fc6cf6c403b85f9e36a@linux-foundation.org>
References: <1478553075-120242-1-git-send-email-thgarnie@google.com>
 <1478553075-120242-2-git-send-email-thgarnie@google.com> <20161107150712.d7b26fc6cf6c403b85f9e36a@linux-foundation.org>
From: Thomas Garnier <thgarnie@google.com>
Date: Mon, 7 Nov 2016 20:22:44 -0800
Message-ID: <CAJcbSZGQEcVtx6BdbSSypEg9qGu8ZFzhiizqPk+Hz71Uc2=NAw@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] mm: Check kmem_create_cache flags are commons
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Mon, Nov 7, 2016 at 3:07 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon,  7 Nov 2016 13:11:15 -0800 Thomas Garnier <thgarnie@google.com> wrote:
>
>> Verify that kmem_create_cache flags are not allocator specific. It is
>> done before removing flags that are not available with the current
>> configuration.
>
> What is the reason for this change?

The current kmem_cache_create removes incorrect flags but do not
validate the callers are using them right. This change will ensure
that callers are not trying to create caches with flags that won't be
used because allocator specific.

It was Christoph's suggestion on the previous versions of the original
patch (the memcg bug fix).

-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
