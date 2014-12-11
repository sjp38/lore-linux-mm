Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 03DEA6B0070
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 10:03:28 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id i57so2338286yha.21
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 07:03:27 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id t35si1510147qge.54.2014.12.11.07.03.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 11 Dec 2014 07:03:26 -0800 (PST)
Date: Thu, 11 Dec 2014 09:03:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
In-Reply-To: <20141211143518.02c781ee@redhat.com>
Message-ID: <alpine.DEB.2.11.1412110902450.28416@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141211143518.02c781ee@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo.kim@lge.com

On Thu, 11 Dec 2014, Jesper Dangaard Brouer wrote:

> It looks like an impressive saving 116 -> 60 cycles.  I just don't see
> the same kind of improvements with my similar tests[1][2].

This is particularly for a CONFIG_PREEMPT kernel. There will be no effect
on !CONFIG_PREEMPT I hope.

> I do see the improvement, but it is not as high as I would have expected.

Do you have CONFIG_PREEMPT set?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
