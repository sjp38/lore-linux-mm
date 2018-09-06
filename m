Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA2F6B79C7
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 13:07:55 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g5-v6so5804107pgq.5
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 10:07:55 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id j24-v6si5536603pfn.363.2018.09.06.10.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 10:07:54 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm: Move page struct poisoning to
 CONFIG_DEBUG_VM_PAGE_INIT_POISON
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
 <20180905211328.3286.71674.stgit@localhost.localdomain>
 <20180906054735.GJ14951@dhcp22.suse.cz>
 <0c1c36f7-f45a-8fe9-dd52-0f60b42064a9@intel.com>
 <20180906151336.GD14951@dhcp22.suse.cz>
 <CAKgT0UfiKWZO6hyjc1RpRTgD+CvM=KnbYokSueLFi7X5h+GMKQ@mail.gmail.com>
 <4f154937-118c-96cf-cf8e-c95a2ca68d44@microsoft.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c5dc8ef6-587d-e286-af80-568094a65007@intel.com>
Date: Thu, 6 Sep 2018 10:07:51 -0700
MIME-Version: 1.0
In-Reply-To: <4f154937-118c-96cf-cf8e-c95a2ca68d44@microsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Alexander Duyck <alexander.duyck@gmail.com>, "mhocko@kernel.org" <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 09/06/2018 09:12 AM, Pasha Tatashin wrote:
> 
> I do not want to make this feature less tested. Poisoning memory allowed
> us to catch corner case bugs like these:
> 
> ab1e8d8960b68f54af42b6484b5950bd13a4054b
> mm: don't allow deferred pages with NEED_PER_CPU_KM
> 
> e181ae0c5db9544de9c53239eb22bc012ce75033
> mm: zero unavailable pages before memmap init
> 
> And several more that were fixed by other people.

Just curious: were these found in the wild, or by a developer doing
normal development having turned on lots of debug options?
