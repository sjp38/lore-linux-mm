Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 925406B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 16:28:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n104so15637193wrb.20
        for <linux-mm@kvack.org>; Tue, 02 May 2017 13:28:59 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id b128si3822443wmb.13.2017.05.02.13.28.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 13:28:58 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id 6so19543151wrb.1
        for <linux-mm@kvack.org>; Tue, 02 May 2017 13:28:58 -0700 (PDT)
Subject: Re: [PATCH man-pages 0/5] {ioctl_}userfaultfd.2: yet another update
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <352eee49-d6d1-3e82-a558-2341484c81f3@gmail.com>
 <20170502094836.GD5910@rapoport-lnx>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <2bd667b5-35d1-6e7f-3f8f-5b4e163618a7@gmail.com>
Date: Tue, 2 May 2017 22:28:56 +0200
MIME-Version: 1.0
In-Reply-To: <20170502094836.GD5910@rapoport-lnx>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On 05/02/2017 11:48 AM, Mike Rapoport wrote:
> On Mon, May 01, 2017 at 08:34:07PM +0200, Michael Kerrisk (man-pages) wrote:
>> Hi Mike,
>>
>> On 05/01/2017 07:43 AM, Mike Rapoport wrote:
>>> Hi Michael,
>>>
>>> These updates pretty much complete the coverage of 4.11 additions, IMHO.
>>
>> Thanks for this, but we still await input from Andrea
>> on various points.
>>
>>> Mike Rapoport (5):
>>>   ioctl_userfaultfd.2: update description of shared memory areas
>>>   ioctl_userfaultfd.2: UFFDIO_COPY: add ENOENT and ENOSPC description
>>>   ioctl_userfaultfd.2: add BUGS section
>>>   userfaultfd.2: add note about asynchronios events delivery
>>>   userfaultfd.2: update VERSIONS section with 4.11 chanegs
>>>
>>>  man2/ioctl_userfaultfd.2 | 35 +++++++++++++++++++++++++++++++++--
>>>  man2/userfaultfd.2       | 15 +++++++++++++++
>>>  2 files changed, 48 insertions(+), 2 deletions(-)
>>
>> I've applied all of the above, and done some light editing.
>>
>> Could you please check my changes in the following commits:
>>
>> 5191c68806c8ac73fdc89586cde434d2766abb5c
>> 265225c1e2311ae26ead116e6c8d2cedd46144fa
> 
> Both are Ok
> Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Thanks for checking, Mike.

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
