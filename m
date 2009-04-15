Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 93A395F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 07:52:22 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so2726326wfa.11
        for <linux-mm@kvack.org>; Wed, 15 Apr 2009 04:53:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090415114154.GI9809@random.random>
References: <20090414143252.GE28265@random.random>
	 <200904150042.15653.nickpiggin@yahoo.com.au>
	 <20090415165431.AC4C.A69D9226@jp.fujitsu.com>
	 <20090415104615.GG9809@random.random>
	 <2f11576a0904150439k6e828307ja97b6729650bcb94@mail.gmail.com>
	 <20090415114154.GI9809@random.random>
Date: Wed, 15 Apr 2009 20:53:11 +0900
Message-ID: <2f11576a0904150453g4332e0d5h5bcad97fac7af24@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

>> Can we assume mmu_notifier is only used by kvm now?
>> if not, we need to make new notifier.
>
> KVM is no fundamentally different from other users in this respect, so
> I don't see why need a new notifier. If it works for others it'll work
> for KVM and the other way around is true too.
>
> mmu notifier users can or cannot take a page pin. KVM does. GRU
> doesn't. XPMEM does. All of them releases any pin after
> mmu_notifier_invalidate_page. All that is important is to run
> mmu_notifier_invalidate_page _after_ the ptep_clear_young_notify, so
> that we don't nuke secondary mappings on the pages unless we really go
> to nuke the pte.

Thank you kindful explain. I understand it :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
