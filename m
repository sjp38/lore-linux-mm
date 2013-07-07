Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9B88C6B0038
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 12:10:28 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id m46so3043956wev.2
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 09:10:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130620055011.GB32061@lge.com>
References: <20130614195500.373711648@linux.com>
	<0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
	<20130619052203.GA12231@lge.com>
	<0000013f5cd71dac-5c834a4e-c521-4d79-aecc-3e7a6671fb8c-000000@email.amazonses.com>
	<20130620015056.GC13026@lge.com>
	<20130620055011.GB32061@lge.com>
Date: Sun, 7 Jul 2013 19:10:27 +0300
Message-ID: <CAOJsxLEjye+R1jT65tWErBnoJ=n8beaTkqLd9YgARwuV_SwdEw@mail.gmail.com>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>

On Thu, Jun 20, 2013 at 8:50 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Thu, Jun 20, 2013 at 10:50:56AM +0900, Joonsoo Kim wrote:
>> Hello, Pekka.
>> I attach a right formatted patch with acked by Christoph and
>> signed off by me.
>>
>> It is based on v3.10-rc6 and top of a patch
>> "slub: do not put a slab to cpu partial list when cpu_partial is 0".
>
> One more change is needed in __slab_free(), so I attach v2.
>
> ------------------8<-------------------------------------
> From 22fef26a9775745a041ca8820971d475714ee351 Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Wed, 19 Jun 2013 14:05:52 +0900
> Subject: [PATCH v2] slub: Make cpu partial slab support configurable
>
> cpu partial support can introduce level of indeterminism that is not
> wanted in certain context (like a realtime kernel). Make it configurable.
>
> This patch is based on Christoph Lameter's
> "slub: Make cpu partial slab support configurable V2".
>
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
