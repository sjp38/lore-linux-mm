Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 445F18E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 12:10:02 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id g26-v6so24847852qkm.20
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 09:10:02 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id n52-v6si26074qtf.91.2018.09.26.09.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 26 Sep 2018 09:10:01 -0700 (PDT)
Date: Wed, 26 Sep 2018 16:10:00 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: remove useless condition in deactivate_slab
In-Reply-To: <1537941430-16217-1-git-send-email-kernelfans@gmail.com>
Message-ID: <0100016616a4f0fd-f0a41fd1-117b-4693-b57a-06262bbb9297-000000@email.amazonses.com>
References: <1537941430-16217-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 26 Sep 2018, Pingfan Liu wrote:

> The var l should be used to reflect the original list, on which the page
> should be. But c->page is not on any list. Furthermore, the current code
> does not update the value of l. Hence remove the related logic

Acked-by: Christoph Lameter <cl@linux.com>
