Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id EC3276B006E
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 16:33:22 -0400 (EDT)
Received: by pacgb13 with SMTP id gb13so19497775pac.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 13:33:22 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id ad6si2824048pbd.44.2015.06.16.13.33.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 13:33:22 -0700 (PDT)
Message-ID: <5580821D.3050508@fb.com>
Date: Tue, 16 Jun 2015 13:07:57 -0700
From: Josef Bacik <jbacik@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tmpfs: truncate at i_size
References: <1432049251-3298-1-git-send-email-jbacik@fb.com> <alpine.LSU.2.11.1506161256490.1050@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1506161256490.1050@eggly.anvils>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/16/2015 01:02 PM, Hugh Dickins wrote:
> On Tue, 19 May 2015, Josef Bacik wrote:
>
>> If we fallocate past i_size with KEEP_SIZE, extend the file to use some but not
>> all of this space, and then truncate(i_size) we won't trim the excess
>> preallocated space.  We decided at LSF that we want to truncate the fallocated
>> bit past i_size when we truncate to i_size, which is what this patch does.
>> Thanks,
>>
>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>
> Sorry for the delay, it's been on my mind but only now I get to it.
> Yes, that was agreed at LSF, and I've checked that indeed tmpfs is
> out of line here: thank you for fixing it.  But I do prefer your
> original more explicit description, so I'll send the patch to akpm
> now for v4.2, with that description instead (plus a reference to LSF).
>

Sounds good, thanks Hugh.

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
