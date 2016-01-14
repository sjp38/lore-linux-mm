Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 06F75828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 11:20:44 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id ba1so497339806obb.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 08:20:44 -0800 (PST)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id r63si8265843oia.54.2016.01.14.08.20.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 08:20:43 -0800 (PST)
Received: by mail-oi0-x243.google.com with SMTP id e195so21479012oig.2
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 08:20:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601140923150.2145@east.gentwo.org>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1452749069-15334-4-git-send-email-iamjoonsoo.kim@lge.com>
	<alpine.DEB.2.20.1601140923150.2145@east.gentwo.org>
Date: Fri, 15 Jan 2016 01:20:43 +0900
Message-ID: <CAAmzW4M61B4h4HgwKDOTdVqDRav6ZOxcK5F7R_4HaitE7c+8zQ@mail.gmail.com>
Subject: Re: [PATCH 03/16] mm/slab: remove the checks for slab implementation bug
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-01-15 0:23 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Thu, 14 Jan 2016, Joonsoo Kim wrote:
>
>> Some of "#if DEBUG" are for reporting slab implementation bug
>> rather than user usecase bug. It's not really needed because slab
>> is stable for a quite long time and it makes code too dirty. This
>> patch remove it.
>
> Maybe better convert them to VM_BUG_ON() or so?

It's one possible solution but I'd like to make slab.c clean
as much as possible. Nowadays, SLAB code isn't changed
so much, therefore I don't think we need to keep them.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
