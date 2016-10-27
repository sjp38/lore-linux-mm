Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABBA6B027E
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 05:35:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b80so6634486wme.5
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 02:35:34 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id q4si7349408wjo.250.2016.10.27.02.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 02:35:32 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id b80so1723906wme.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 02:35:32 -0700 (PDT)
Subject: Re: [PATCH v2] mm: remove unnecessary __get_user_pages_unlocked()
 calls
References: <20161025233609.5601-1-lstoakes@gmail.com>
 <20161026092548.12712-1-lstoakes@gmail.com>
 <20161026171207.e76e4420dd95afcf16cc7c59@linux-foundation.org>
 <1019451e-1f91-57d4-11c8-79e08c86afe1@redhat.com>
 <20161027093259.GA1135@lucifer>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <9977f8b1-2781-4325-fc07-29a282f7908b@redhat.com>
Date: Thu, 27 Oct 2016 11:35:30 +0200
MIME-Version: 1.0
In-Reply-To: <20161027093259.GA1135@lucifer>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org



On 27/10/2016 11:32, Lorenzo Stoakes wrote:
> On Thu, Oct 27, 2016 at 11:27:24AM +0200, Paolo Bonzini wrote:
>>
>>
>> On 27/10/2016 02:12, Andrew Morton wrote:
>>>
>>>
>>>> Subject: [PATCH v2] mm: remove unnecessary __get_user_pages_unlocked() calls
>>>
>>> The patch is rather misidentified.
>>>
>>>>  virt/kvm/async_pf.c | 7 ++++---
>>>>  virt/kvm/kvm_main.c | 5 ++---
>>>>  2 files changed, 6 insertions(+), 6 deletions(-)
>>>
>>> It's a KVM patch and should have been called "kvm: remove ...".
>>> Possibly the KVM maintainers will miss it for this reason.
>>
>> I noticed it, but I confused it with "mm: unexport __get_user_pages()".
>>
>> I'll merge this through the KVM tree for -rc3.
> 
> Actually Paolo could you hold off on this? As I think on reflection it'd make
> more sense to batch this change up with a change to get_user_pages_remote() as
> suggested by Michal.

Okay.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
