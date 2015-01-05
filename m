Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id BE0186B006C
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 09:53:22 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id f12so13470557qad.4
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 06:53:22 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id s106si60542966qgd.103.2015.01.05.06.53.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 06:53:21 -0800 (PST)
Date: Mon, 5 Jan 2015 08:53:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm: don't use compound_head() in
 virt_to_head_page()
In-Reply-To: <1420421765-3209-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1501050852380.24090@gentwo.org>
References: <1420421765-3209-1-git-send-email-iamjoonsoo.kim@lge.com> <1420421765-3209-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>

On Mon, 5 Jan 2015, Joonsoo Kim wrote:

> This patch implements compound_head_fast() which is similar with
> compound_head() except tail flag race handling. And then,
> virt_to_head_page() uses this optimized function to improve performance.

Yeah that is how it was before and how it should be

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
