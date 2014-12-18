Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id DCE4D6B0075
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 10:08:23 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id gq1so3658737obb.9
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 07:08:23 -0800 (PST)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id a196si1573899oig.101.2014.12.18.07.08.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 07:08:22 -0800 (PST)
Received: by mail-oi0-f48.google.com with SMTP id u20so489612oif.7
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 07:08:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1412180856400.2593@gentwo.org>
References: <20141210163017.092096069@linux.com>
	<20141215075933.GD4898@js1304-P5Q-DELUXE>
	<CAAmzW4NCpx5aJyW36fgOfu3EaDj6=uv6MUiBC+a0ggePWPXndQ@mail.gmail.com>
	<alpine.DEB.2.11.1412170935480.2047@gentwo.org>
	<CAAmzW4Oyw974Zg274C2-1BcOphEJY63gx7v2QTQuULOJBzknig@mail.gmail.com>
	<alpine.DEB.2.11.1412180856400.2593@gentwo.org>
Date: Fri, 19 Dec 2014 00:08:21 +0900
Message-ID: <CAAmzW4PicQ-MaFqpCGj-FN3vx4UeMY+VF_0UrF8+2_B_8kz_bQ@mail.gmail.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>

2014-12-18 23:57 GMT+09:00 Christoph Lameter <cl@linux.com>:
>
> On Thu, 18 Dec 2014, Joonsoo Kim wrote:
>> > Good idea. How does this affect the !CONFIG_PREEMPT case?
>>
>> One more this_cpu_xxx makes fastpath slow if !CONFIG_PREEMPT.
>> Roughly 3~5%.
>>
>> We can deal with each cases separately although it looks dirty.
>
> Ok maybe you can come up with a solution that is as clean as possible?

Okay. Will do!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
