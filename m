Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35E4E6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:03:30 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x11so118946984qka.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:03:30 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id j38si17710802qkh.146.2016.10.17.05.03.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 05:03:29 -0700 (PDT)
Received: by mail-qk0-x22d.google.com with SMTP id f128so221258381qkb.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:03:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5804305F.4030302@huawei.com>
References: <1476331337-17253-1-git-send-email-zhongjiang@huawei.com> <5804305F.4030302@huawei.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 17 Oct 2016 14:03:28 +0200
Message-ID: <CAMJBoFMcnH3ZPQpG=oAjD=K64O7MX_BdFvHvccvgCV4nFSfxXA@mail.gmail.com>
Subject: Re: [PATCH v2] z3fold: fix the potential encode bug in encod_handle
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Dave Chinner <david@fromorbit.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi Zhong Jiang,

On Mon, Oct 17, 2016 at 3:58 AM, zhong jiang <zhongjiang@huawei.com> wrote:
> Hi,  Vitaly
>
> About the following patch,  is it right?
>
> Thanks
> zhongjiang
> On 2016/10/13 12:02, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> At present, zhdr->first_num plus bud can exceed the BUDDY_MASK
>> in encode_handle, it will lead to the the caller handle_to_buddy
>> return the error value.
>>
>> The patch fix the issue by changing the BUDDY_MASK to PAGE_MASK,
>> it will be consistent with handle_to_z3fold_header. At the same time,
>> change the BUDDY_MASK to PAGE_MASK in handle_to_buddy is better.

are you seeing problems with the existing code? first_num should wrap around
BUDDY_MASK and this should be ok because it is way bigger than the number
of buddies.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
