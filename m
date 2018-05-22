Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0AA6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 17:07:37 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t5-v6so12892691ply.13
        for <linux-mm@kvack.org>; Tue, 22 May 2018 14:07:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k6-v6si13466601pgq.85.2018.05.22.14.07.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 14:07:36 -0700 (PDT)
Date: Tue, 22 May 2018 14:07:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/2] kasan: fix memory hotplug during boot
Message-Id: <20180522140735.71dcd92e7b013629a7f15f91@linux-foundation.org>
In-Reply-To: <09c36096-f8c8-b9e9-0bed-113e494f159a@virtuozzo.com>
References: <20180522100756.18478-1-david@redhat.com>
	<20180522100756.18478-3-david@redhat.com>
	<f4378c56-acc2-a5cf-724c-76cffee28235@virtuozzo.com>
	<ff21c6e7-cb32-60d8-abd3-dfc6be3d05f7@redhat.com>
	<09c36096-f8c8-b9e9-0bed-113e494f159a@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "open list:KASAN" <kasan-dev@googlegroups.com>

On Tue, 22 May 2018 22:50:12 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

> 
> 
> On 05/22/2018 07:36 PM, David Hildenbrand wrote:
> > On 22.05.2018 18:26, Andrey Ryabinin wrote:
> >>
> >>
> >> On 05/22/2018 01:07 PM, David Hildenbrand wrote:
> >>> Using module_init() is wrong. E.g. ACPI adds and onlines memory before
> >>> our memory notifier gets registered.
> >>>
> >>> This makes sure that ACPI memory detected during boot up will not
> >>> result in a kernel crash.
> >>>
> >>> Easily reproducable with QEMU, just specify a DIMM when starting up.
> >>
> >>          reproducible
> >>>
> >>> Signed-off-by: David Hildenbrand <david@redhat.com>
> >>> ---
> >>
> >> Fixes: fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
> >> Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> >> Cc: <stable@vger.kernel.org>
> > 
> > Think this even dates back to:
> > 
> > 786a8959912e ("kasan: disable memory hotplug")
> > 
> 
> Indeed.

Is a backport to -stable justified for either of these patches?
