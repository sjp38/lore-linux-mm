Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id EA3DC6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 10:24:46 -0400 (EDT)
Received: by mail-vb0-f48.google.com with SMTP id w16so455902vbf.21
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 07:24:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <00000140ab69e6be-3b2999b6-93b4-4b22-a91f-8929aee5238f-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1377161065-30552-6-git-send-email-iamjoonsoo.kim@lge.com>
	<00000140a72870a6-f7c87696-ecbc-432c-9f41-93f414c0c623-000000@email.amazonses.com>
	<20130823065315.GG22605@lge.com>
	<00000140ab69e6be-3b2999b6-93b4-4b22-a91f-8929aee5238f-000000@email.amazonses.com>
Date: Fri, 23 Aug 2013 23:24:45 +0900
Message-ID: <CAAmzW4NZHXXX08tdQitwapfi8raQ-BTRry92A0jdFQkm0vaqxw@mail.gmail.com>
Subject: Re: [PATCH 05/16] slab: remove cachep in struct slab_rcu
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2013/8/23 Christoph Lameter <cl@linux.com>:
> On Fri, 23 Aug 2013, Joonsoo Kim wrote:
>
>> On Thu, Aug 22, 2013 at 05:53:00PM +0000, Christoph Lameter wrote:
>> > On Thu, 22 Aug 2013, Joonsoo Kim wrote:
>> >
>> > > We can get cachep using page in struct slab_rcu, so remove it.
>> >
>> > Ok but this means that we need to touch struct page. Additional cacheline
>> > in cache footprint.
>>
>> In following patch, we overload RCU_HEAD to LRU of struct page and
>> also overload struct slab to struct page. So there is no
>> additional cacheline footprint at final stage.
>
> If you do not use rcu (standard case) then you have an additional
> cacheline.
>

I don't get it. This patch only affect to the rcu case, because it
change the code
which is in kmem_rcu_free(). It doesn't touch anything in standard case.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
