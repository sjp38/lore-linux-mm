Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D269D6B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 16:23:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g12so15619119wrg.15
        for <linux-mm@kvack.org>; Tue, 02 May 2017 13:23:33 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 45si10758917wry.54.2017.05.02.13.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 13:23:32 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id y10so7483751wmh.0
        for <linux-mm@kvack.org>; Tue, 02 May 2017 13:23:32 -0700 (PDT)
Subject: Re: [PATCH man-pages 1/5] ioctl_userfaultfd.2: update description of
 shared memory areas
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493617399-20897-2-git-send-email-rppt@linux.vnet.ibm.com>
 <7ec5dfc0-9d84-e142-bfaa-d96383acbee9@gmail.com>
 <20170502093110.GA5910@rapoport-lnx>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <1586d8ea-342c-c652-86f4-a7fafc8c7be6@gmail.com>
Date: Tue, 2 May 2017 22:23:28 +0200
MIME-Version: 1.0
In-Reply-To: <20170502093110.GA5910@rapoport-lnx>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On 05/02/2017 11:31 AM, Mike Rapoport wrote:
> On Mon, May 01, 2017 at 08:33:31PM +0200, Michael Kerrisk (man-pages) wrote:
>> Hello Mike,
>>
>> I've applied this patch, but  have a question.
>>
>> On 05/01/2017 07:43 AM, Mike Rapoport wrote:
>>> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
>>> ---
>>>  man2/ioctl_userfaultfd.2 | 13 +++++++++++--
>>>  1 file changed, 11 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
>>> index 889feb9..6edd396 100644
>>> --- a/man2/ioctl_userfaultfd.2
>>> +++ b/man2/ioctl_userfaultfd.2
>>> @@ -181,8 +181,17 @@ virtual memory areas
>>>  .TP
>>>  .B UFFD_FEATURE_MISSING_SHMEM
>>>  If this feature bit is set,
>>> -the kernel supports registering userfaultfd ranges on tmpfs
>>> -virtual memory areas
>>> +the kernel supports registering userfaultfd ranges on shared memory areas.
>>> +This includes all kernel shared memory APIs:
>>> +System V shared memory,
>>> +tmpfs,
>>> +/dev/zero,
>>> +.BR mmap(2)
>>> +with
>>> +.I MAP_SHARED
>>> +flag set,
>>> +.BR memfd_create (2),
>>> +etc.
>>>  
>>>  The returned
>>>  .I ioctls
>>
>> Does the change in this patch represent a change that occurred in
>> Linux 4.11? If so, I think this needs to be said explicitly in the text.
> 
> The patch only extends the description of UFFD_FEATURE_MISSING_SHMEM. The
> feature is indeed available from 4.11, but that is said a few lives above
> (line 136 in ioctl_userfaultfd.2)

Okay -- thanks for the clarification.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
