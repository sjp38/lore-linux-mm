Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63A666B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:10:10 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d186so105007142lfg.7
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:10:10 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id fg1si42610178wjc.27.2016.10.17.10.10.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 10:10:09 -0700 (PDT)
Message-ID: <5804C88F.7040000@huawei.com>
Date: Mon, 17 Oct 2016 20:48:15 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] z3fold: fix the potential encode bug in encod_handle
References: <1476331337-17253-1-git-send-email-zhongjiang@huawei.com> <5804305F.4030302@huawei.com> <CAMJBoFMcnH3ZPQpG=oAjD=K64O7MX_BdFvHvccvgCV4nFSfxXA@mail.gmail.com>
In-Reply-To: <CAMJBoFMcnH3ZPQpG=oAjD=K64O7MX_BdFvHvccvgCV4nFSfxXA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 2016/10/17 20:03, Vitaly Wool wrote:
> Hi Zhong Jiang,
>
> On Mon, Oct 17, 2016 at 3:58 AM, zhong jiang <zhongjiang@huawei.com> wrote:
>> Hi,  Vitaly
>>
>> About the following patch,  is it right?
>>
>> Thanks
>> zhongjiang
>> On 2016/10/13 12:02, zhongjiang wrote:
>>> From: zhong jiang <zhongjiang@huawei.com>
>>>
>>> At present, zhdr->first_num plus bud can exceed the BUDDY_MASK
>>> in encode_handle, it will lead to the the caller handle_to_buddy
>>> return the error value.
>>>
>>> The patch fix the issue by changing the BUDDY_MASK to PAGE_MASK,
>>> it will be consistent with handle_to_z3fold_header. At the same time,
>>> change the BUDDY_MASK to PAGE_MASK in handle_to_buddy is better.
> are you seeing problems with the existing code? first_num should wrap around
> BUDDY_MASK and this should be ok because it is way bigger than the number
> of buddies.
>
> ~vitaly
>
> .
>
 first_num plus buddies can exceed the BUDDY_MASK. is it right?
 (first_num + buddies) & BUDDY_MASK may be a smaller value than first_num.

  but (handle - zhdr->first_num) & BUDDY_MASK will return incorrect value
  in handle_to_buddy.

  Thanks
  zhongjiang
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
