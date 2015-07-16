Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id E95872802F6
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 07:35:15 -0400 (EDT)
Received: by qgy5 with SMTP id 5so30955768qgy.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 04:35:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m77si9168871qgm.53.2015.07.16.04.35.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 04:35:15 -0700 (PDT)
Subject: Re: [PATCH -mm v8 5/7] mmu-notifier: add clear_young callback
References: <cover.1436967694.git.vdavydov@parallels.com>
 <82693bd5b5dbf4e65657fa22288942650aa04a0a.1436967694.git.vdavydov@parallels.com>
 <CAJu=L58yzBr8+XaV90x+S60YnJzd7Yr2fDEgaQ0bcCKpwzSAhw@mail.gmail.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <55A796E6.3090603@redhat.com>
Date: Thu, 16 Jul 2015 13:35:02 +0200
MIME-Version: 1.0
In-Reply-To: <CAJu=L58yzBr8+XaV90x+S60YnJzd7Yr2fDEgaQ0bcCKpwzSAhw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>, Vladimir Davydov <vdavydov@parallels.com>, kvm@vger.kernel.org, Eric Northup <digitaleric@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org



On 15/07/2015 21:16, Andres Lagar-Cavilla wrote:
>> > +static int kvm_mmu_notifier_clear_young(struct mmu_notifier *mn,
>> > +                                       struct mm_struct *mm,
>> > +                                       unsigned long start,
>> > +                                       unsigned long end)
>> > +{
>> > +       struct kvm *kvm = mmu_notifier_to_kvm(mn);
>> > +       int young, idx;
> For reclaim, the clear_flush_young notifier may blow up the secondary
> pte to estimate the access pattern, depending on hardware support (EPT
> access bits available in Haswell onwards, not sure about AMD, PPC,
> etc).

It seems like this problem is limited to pre-Haswell EPT.

I'm okay with the patch.  If we find problems later we can always add a
parameter to kvm_age_hva so that it effectively doesn't do anything on
clear_young.

Acked-by: Paolo Bonzini <pbonzini@redhat.com>

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
