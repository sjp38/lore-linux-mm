Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF7283200
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 13:28:03 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j5so70950904pfb.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 10:28:03 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id m123si3959372pga.357.2017.03.08.10.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 10:28:02 -0800 (PST)
Subject: Re: [PATCH] mm: drop "wait" parameter from write_one_page
References: <20170305132313.5840-1-jlayton@redhat.com>
 <f7276bea-141f-fc12-9d0a-5ce93700f40a@nvidia.com>
 <1488972605.2802.3.camel@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c1fbe4bc-79ee-07a0-8f3a-cd8c318c80be@nvidia.com>
Date: Wed, 8 Mar 2017 10:27:30 -0800
MIME-Version: 1.0
In-Reply-To: <1488972605.2802.3.camel@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 03/08/2017 03:30 AM, Jeff Layton wrote:
[...]
> Thanks for having a look. That blurb in the changelog refers to the
> kerneldoc comment over write_one_page below...
>
>>
>>   No existing caller uses this on normal files, so
>>> none of them need it.
>>>
>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
[...]
>>>
>>>  /**
>>> - * write_one_page - write out a single page and optionally wait on I/O
>>> + * write_one_page - write out a single page and wait on I/O
>>>   * @page: the page to write
>>> - * @wait: if true, wait on writeout
>>>   *
>>>   * The page must be locked by the caller and will be unlocked upon return.
>>>   *
>>> - * write_one_page() returns a negative error code if I/O failed.
>>> + * write_one_page() returns a negative error code if I/O failed. Note that
>>> + * the address_space is not marked for error. The caller must do this if
>>> + * needed.
>
> ...specifically the single sentence in the comment above.
>
> As I said, none of the existing callers need to set an error in the
> mapping when this fails, so I just added this to make it clear for any
> new callers in the future.

Yes, somehow, even in this tiny patchset, I missed those two new comment lines. 
arghh. :)

Well, everything looks great, then.

thanks,
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
