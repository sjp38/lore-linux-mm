Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9EF8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 10:32:12 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id x82so20038980ita.9
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 07:32:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h68sor15020524iof.5.2018.12.26.07.32.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Dec 2018 07:32:11 -0800 (PST)
MIME-Version: 1.0
References: <20181226023534.64048-1-cai@lca.pw> <CAKv+Gu_fiEDffKq_fONBYTOdSk-L7__+LgNEyVaNF3FGzBfAow@mail.gmail.com>
 <403405f1-b702-2feb-4616-35fc3dc3133e@lca.pw>
In-Reply-To: <403405f1-b702-2feb-4616-35fc3dc3133e@lca.pw>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 26 Dec 2018 16:31:59 +0100
Message-ID: <CAKv+Gu_e=NkKZ5C+KzBmgg2VMXNKPqXcPON8heRd0F_iW+aaEQ@mail.gmail.com>
Subject: Re: [PATCH -mmotm] efi: drop kmemleak_ignore() for page allocator
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux-MM <linux-mm@kvack.org>, linux-efi <linux-efi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 26 Dec 2018 at 16:13, Qian Cai <cai@lca.pw> wrote:
>
> On 12/26/18 7:02 AM, Ard Biesheuvel wrote:
> > On Wed, 26 Dec 2018 at 03:35, Qian Cai <cai@lca.pw> wrote:
> >>
> >> a0fc5578f1d (efi: Let kmemleak ignore false positives) is no longer
> >> needed due to efi_mem_reserve_persistent() uses __get_free_page()
> >> instead where kmemelak is not able to track regardless. Otherwise,
> >> kernel reported "kmemleak: Trying to color unknown object at
> >> 0xffff801060ef0000 as Black"
> >>
> >> Signed-off-by: Qian Cai <cai@lca.pw>
> >
> > Why are you sending this to -mmotm?
> >
> > Andrew, please disregard this patch. This is EFI/tip material.
>
> Well, I'd like to primarily develop on the -mmotm tree as it fits in a
> sweet-spot where the mainline is too slow and linux-next is too chaotic.
>
> The bug was reproduced and the patch was tested on -mmotm. If for every bugs
> people found in -mmtom, they have to check out the corresponding sub-system tree
> and reproduce/verify the bug over there, that is quite a burden to bear.
>

Yes. But you know what? We all have our burden to bear, and shifting
this burden to someone else, in this case the subsystem maintainer who
typically deals with a sizable workload already, is not a very nice
thing to do.

> That's why sub-system maintainers are copied on those patches, so they can
> decide to fix directly in the sub-system tree instead of -mmotm, and then it
> will propagate to -mmotm one way or another.
>

Please stop sending EFI patches if you can't be bothered to
test/reproduce against the EFI tree.

Thanks,
Ard.
