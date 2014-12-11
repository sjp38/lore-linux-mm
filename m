Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 813166B0038
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 12:18:34 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id y20so5282591ier.0
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 09:18:34 -0800 (PST)
Received: from resqmta-po-05v.sys.comcast.net ([2001:558:fe16:19:250:56ff:feb0:2995])
        by mx.google.com with ESMTPS id n4si1912705ige.9.2014.12.11.09.18.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 11 Dec 2014 09:18:33 -0800 (PST)
Date: Thu, 11 Dec 2014 11:18:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
In-Reply-To: <20141211175058.64a1c2fc@redhat.com>
Message-ID: <alpine.DEB.2.11.1412111117510.31381@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141211143518.02c781ee@redhat.com> <alpine.DEB.2.11.1412110902450.28416@gentwo.org> <20141211175058.64a1c2fc@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo.kim@lge.com

On Thu, 11 Dec 2014, Jesper Dangaard Brouer wrote:

> I was expecting to see at least (specifically) 4.291 ns improvement, as
> this is the measured[1] cost of preempt_{disable,enable] on my system.

Right. Those calls are taken out of the fastpaths by this patchset for
the CONFIG_PREEMPT case. So the numbers that you got do not make much
sense to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
