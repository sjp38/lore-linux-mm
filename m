Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD4E28033A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:25:07 -0400 (EDT)
Received: by lahe2 with SMTP id e2so639733lah.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 08:25:06 -0700 (PDT)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [5.255.216.100])
        by mx.google.com with ESMTPS id dh9si10146403lac.35.2015.07.17.08.25.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 08:25:05 -0700 (PDT)
Message-ID: <55A91E4D.2080203@yandex-team.ru>
Date: Fri, 17 Jul 2015 18:25:01 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/slub: disable merging after enabling debug in
 runtime
References: <20150714131704.21442.17939.stgit@buzz> <20150714131705.21442.99279.stgit@buzz> <alpine.DEB.2.11.1507141304430.28065@east.gentwo.org> <CALYGNiPKgfE+KNNgmW0ZGrFqU4NSsz_vm14Zu2gXFyjPWnE57g@mail.gmail.com> <alpine.DEB.2.11.1507141616440.12219@east.gentwo.org> <CALYGNiM6iKzwSiKRu79N-pjnSQZR_P3t9q50vV3cHtvLQz=dCA@mail.gmail.com> <alpine.DEB.2.11.1507171008080.17929@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1507171008080.17929@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 17.07.2015 18:09, Christoph Lameter wrote:
> On Fri, 17 Jul 2015, Konstantin Khlebnikov wrote:
>
>>> Hrm.... Bad. Maybe drop the checks for the debug options that can be
>>> configured when merging slabs? They do not influence the object layout
>>> per definition.
>>
>> I don't understand that. Debug options do changes in object layout.
>
> Only some debug options change the object layout and those are alrady
> forbidden for caches with objects.

Ah, ok. I've missed that any_slab_objects(). Never used enabling these 
features in runtime.

>
>> Since they add significant performance overhead and cannot be undone in runtime
>> it's unlikely that anyone who uses them don't care about merging after that.
>
> Those that do not affect the object layout can be undone.

Except __CMPXCHG_DOUBLE. But I guess we can use stop-machine for that.

>
>> Also I don't see how merging could affect debugging in positive way
>> (except debugging bugs in merging logic itself).
>
> The problem here is that debugging is switched on for slabs that are
> already merged right?
>

Right. And looks like problem only in conflicting sysfs names.

-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
