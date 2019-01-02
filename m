Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 98E388E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 16:44:00 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so33483356pfq.8
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 13:44:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2sor20302912plh.10.2019.01.02.13.43.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 13:43:59 -0800 (PST)
Date: Wed, 2 Jan 2019 13:43:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/slub.c: freelist is ensured to be NULL when new_slab()
 fails
In-Reply-To: <20181229062512.30469-1-rocking@whu.edu.cn>
Message-ID: <alpine.DEB.2.21.1901021343450.69024@chino.kir.corp.google.com>
References: <20181229062512.30469-1-rocking@whu.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peng Wang <rocking@whu.edu.cn>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 29 Dec 2018, Peng Wang wrote:

> new_slab_objects() will return immediately if freelist is not NULL.
> 
>          if (freelist)
>                  return freelist;
> 
> One more assignment operation could be avoided.
> 
> Signed-off-by: Peng Wang <rocking@whu.edu.cn>

Acked-by: David Rientjes <rientjes@google.com>
