Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id C04DA6B000D
	for <linux-mm@kvack.org>; Sun, 24 Jun 2018 16:10:41 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id f22-v6so2219340lfa.11
        for <linux-mm@kvack.org>; Sun, 24 Jun 2018 13:10:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g129-v6sor2656246lfg.75.2018.06.24.13.10.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Jun 2018 13:10:40 -0700 (PDT)
Date: Sun, 24 Jun 2018 23:10:37 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 0/3] mm: use irq locking suffix instead
 local_irq_disable()
Message-ID: <20180624201037.nsbkzq4bqcn53r5h@esperanza>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
 <20180622143900.802fbfa2236d8f5bba965e2e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622143900.802fbfa2236d8f5bba965e2e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org, tglx@linutronix.de, Kirill Tkhai <ktkhai@virtuozzo.com>

On Fri, Jun 22, 2018 at 02:39:00PM -0700, Andrew Morton wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/list_lru.c: fold __list_lru_count_one() into its caller
> 
> __list_lru_count_one() has a single callsite.
> 
> Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
