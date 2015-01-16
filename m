Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9192C6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 22:30:15 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id b16so1427464igk.5
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 19:30:15 -0800 (PST)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id ba10si6005907icc.24.2015.01.15.19.30.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 19:30:14 -0800 (PST)
Date: Thu, 15 Jan 2015 21:30:12 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/2] mm: don't use compound_head() in
 virt_to_head_page()
In-Reply-To: <20150115171646.8fec31e2.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1501152128460.13976@gentwo.org>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com> <1421307633-24045-2-git-send-email-iamjoonsoo.kim@lge.com> <20150115171646.8fec31e2.akpm@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>

On Thu, 15 Jan 2015, Andrew Morton wrote:

> And perhaps some explanation here as to why virt_to_head_page() can
> safely use compound_head_fast().  There's an assumption here that
> nobody will be dismantling the compound page while virt_to_head_page()
> is in progress, yes?  And this assumption also holds for the calling
> code, because otherwise the virt_to_head_page() return value is kinda
> meaningless.

I think this assumption is pretty natural to make. A coupound_head that
works well while dismantling a compound page should be marked specially
and Joonsoo's definition should be the standard.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
