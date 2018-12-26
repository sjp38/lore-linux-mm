Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id F167C8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 10:13:27 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id u197so20672242qka.8
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 07:13:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k96sor11920516qkh.94.2018.12.26.07.13.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Dec 2018 07:13:26 -0800 (PST)
Subject: Re: [PATCH -mmotm] efi: drop kmemleak_ignore() for page allocator
References: <20181226023534.64048-1-cai@lca.pw>
 <CAKv+Gu_fiEDffKq_fONBYTOdSk-L7__+LgNEyVaNF3FGzBfAow@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <403405f1-b702-2feb-4616-35fc3dc3133e@lca.pw>
Date: Wed, 26 Dec 2018 10:13:25 -0500
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu_fiEDffKq_fONBYTOdSk-L7__+LgNEyVaNF3FGzBfAow@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux-MM <linux-mm@kvack.org>, linux-efi <linux-efi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 12/26/18 7:02 AM, Ard Biesheuvel wrote:
> On Wed, 26 Dec 2018 at 03:35, Qian Cai <cai@lca.pw> wrote:
>>
>> a0fc5578f1d (efi: Let kmemleak ignore false positives) is no longer
>> needed due to efi_mem_reserve_persistent() uses __get_free_page()
>> instead where kmemelak is not able to track regardless. Otherwise,
>> kernel reported "kmemleak: Trying to color unknown object at
>> 0xffff801060ef0000 as Black"
>>
>> Signed-off-by: Qian Cai <cai@lca.pw>
> 
> Why are you sending this to -mmotm?
> 
> Andrew, please disregard this patch. This is EFI/tip material.

Well, I'd like to primarily develop on the -mmotm tree as it fits in a
sweet-spot where the mainline is too slow and linux-next is too chaotic.

The bug was reproduced and the patch was tested on -mmotm. If for every bugs
people found in -mmtom, they have to check out the corresponding sub-system tree
and reproduce/verify the bug over there, that is quite a burden to bear.

That's why sub-system maintainers are copied on those patches, so they can
decide to fix directly in the sub-system tree instead of -mmotm, and then it
will propagate to -mmotm one way or another.
