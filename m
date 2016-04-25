Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FEB46B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:44:00 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id n2so258668107obo.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:44:00 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id w13si579502oie.188.2016.04.25.14.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 14:43:59 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id r78so191580585oie.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:43:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160425143850.b767ca9602fc1be9e13462a5@linux-foundation.org>
References: <1461616763-60246-1-git-send-email-thgarnie@google.com>
	<20160425141046.d14466272ea246dd0374ea43@linux-foundation.org>
	<CAJcbSZG4wcW=nKSjuzyZpkvTSwYn1eyAok0QtXsgDLyjARz=ig@mail.gmail.com>
	<CAJcbSZGCywmo_hUCE1DAcPjr0FHcMm0ewAVkCH9jRecmJZBtZQ@mail.gmail.com>
	<20160425143850.b767ca9602fc1be9e13462a5@linux-foundation.org>
Date: Mon, 25 Apr 2016 14:43:58 -0700
Message-ID: <CAJcbSZE6srG0zgb5Jt8WF9RiTewhn9PEU_3mbzHw2jt3HKdRHg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: SLAB freelist randomization
From: Thomas Garnier <thgarnie@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kees Cook <keescook@chromium.org>, Greg Thelen <gthelen@google.com>, Laura Abbott <labbott@fedoraproject.org>, kernel-hardening@lists.openwall.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Apr 25, 2016 at 2:38 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 25 Apr 2016 14:14:33 -0700 Thomas Garnier <thgarnie@google.com> wrote:
>
>> >>> +     /* Get best entropy at this stage */
>> >>> +     get_random_bytes_arch(&seed, sizeof(seed));
>> >>
>> >> See concerns in other email - isn't this a no-op if CONFIG_ARCH_RANDOM=n?
>> >>
>>
>> The arch_* functions will return 0 which will break the loop in
>> get_random_bytes_arch and make it uses extract_entropy (as does
>> get_random_bytes).
>> (cf http://lxr.free-electrons.com/source/drivers/char/random.c#L1335)
>>
>
> oop, sorry, I misread the code.
>
> (and the get_random_bytes_arch() comment "This function will use the
> architecture-specific hardware random number generator if it is
> available" is misleading, so there)

No problem, better double check it. I agree it is misleading.

Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
