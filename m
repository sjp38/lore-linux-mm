Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A97196B02A1
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 09:53:07 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p36-v6so9133534qta.10
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 06:53:07 -0700 (PDT)
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id w137-v6si1836657qkb.257.2018.10.25.06.53.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 06:53:06 -0700 (PDT)
Date: Thu, 25 Oct 2018 13:53:06 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm, slub: unify access to s->cpu_slab by replacing
 raw_cpu_ptr() with this_cpu_ptr()
In-Reply-To: <20181025094437.18951-2-richard.weiyang@gmail.com>
Message-ID: <01000166ab8007d8-7d1d4733-c13d-4e9d-b485-ae0846a5d78c-000000@email.amazonses.com>
References: <20181025094437.18951-1-richard.weiyang@gmail.com> <20181025094437.18951-2-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, 25 Oct 2018, Wei Yang wrote:

> In current code, we use two forms to access s->cpu_slab
>
>   * raw_cpu_ptr()
>   * this_cpu_ptr()

Ok the only difference is that for CONFIG_DEBUG_PREEMPT we will do the
debug checks twice.

That tolerable I think but is this really a worthwhile change?
