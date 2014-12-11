Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8168E6B006C
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 10:01:05 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id rp18so4777631iec.25
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 07:01:05 -0800 (PST)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id o93si945578ioi.13.2014.12.11.07.01.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 11 Dec 2014 07:01:04 -0800 (PST)
Date: Thu, 11 Dec 2014 09:01:02 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
In-Reply-To: <20141211141938.6420b94a@redhat.com>
Message-ID: <alpine.DEB.2.11.1412110900370.28416@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141210163033.717707217@linux.com> <CAOJsxLFEN_w7q6NvbxkH2KTujB9auLkQgskLnGtN9iBQ4hV9sw@mail.gmail.com> <alpine.DEB.2.11.1412101107350.6291@gentwo.org> <CAOJsxLH4BGT9rGgg_4nxUMgW3sdEzLrmX2WtM8Ld3aytdR5e8g@mail.gmail.com>
 <alpine.DEB.2.11.1412101136520.6639@gentwo.org> <20141211141938.6420b94a@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com

On Thu, 11 Dec 2014, Jesper Dangaard Brouer wrote:

> If I explicitly add "inline", then it gets inlined, and performance is good again.

Ok adding inline for the next release.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
