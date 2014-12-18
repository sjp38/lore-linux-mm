Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 369736B0072
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 09:57:44 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id k15so903201qaq.27
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 06:57:44 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id s104si8410046qge.78.2014.12.18.06.57.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 06:57:43 -0800 (PST)
Date: Thu, 18 Dec 2014 08:57:39 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
In-Reply-To: <CAAmzW4Oyw974Zg274C2-1BcOphEJY63gx7v2QTQuULOJBzknig@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1412180856400.2593@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141215075933.GD4898@js1304-P5Q-DELUXE> <CAAmzW4NCpx5aJyW36fgOfu3EaDj6=uv6MUiBC+a0ggePWPXndQ@mail.gmail.com> <alpine.DEB.2.11.1412170935480.2047@gentwo.org>
 <CAAmzW4Oyw974Zg274C2-1BcOphEJY63gx7v2QTQuULOJBzknig@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>


On Thu, 18 Dec 2014, Joonsoo Kim wrote:
> > Good idea. How does this affect the !CONFIG_PREEMPT case?
>
> One more this_cpu_xxx makes fastpath slow if !CONFIG_PREEMPT.
> Roughly 3~5%.
>
> We can deal with each cases separately although it looks dirty.

Ok maybe you can come up with a solution that is as clean as possible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
