Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 648276B0253
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 17:56:05 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id 198so4590773ybl.17
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 14:56:05 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d8si2497210ywj.643.2017.11.20.14.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 14:56:04 -0800 (PST)
Subject: Re: [RFC PATCH 0/3] restructure memfd code
References: <20171109014109.21077-1-mike.kravetz@oracle.com>
 <CAJ+F1CKsehGaan8ZgSNEBQ6sveyMVYH5Wr4ggys-czpmbV8Qvg@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <2ab0b1e1-5f56-afb2-8516-a6098234dba8@oracle.com>
Date: Mon, 20 Nov 2017 14:55:55 -0800
MIME-Version: 1.0
In-Reply-To: <CAJ+F1CKsehGaan8ZgSNEBQ6sveyMVYH5Wr4ggys-czpmbV8Qvg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@gmail.com>
Cc: linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, David Herrmann <dh.herrmann@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On 11/20/2017 02:28 AM, Marc-AndrA(C) Lureau wrote:
> Hi
> 
> On Thu, Nov 9, 2017 at 2:41 AM, Mike Kravetz <mike.kravetz@oracle.com> wrote:
>> With the addition of memfd hugetlbfs support, we now have the situation
>> where memfd depends on TMPFS -or- HUGETLBFS.  Previously, memfd was only
>> supported on tmpfs, so it made sense that the code resides in shmem.c.
>>
>> This patch series moves the memfd code to separate files (memfd.c and
>> memfd.h).  It creates a new config option MEMFD_CREATE that is defined
>> if either TMPFS or HUGETLBFS is defined.
> 
> That looks good to me
> 
>>
>> In the current code, memfd is only functional if TMPFS is defined.  If
>> HUGETLFS is defined and TMPFS is not defined, then memfd functionality
>> will not be available for hugetlbfs.  This does not cause BUGs, just a
>> potential lack of desired functionality.
>>
> 
> Indeed
> 
>> Another way to approach this issue would be to simply make HUGETLBFS
>> depend on TMPFS.
>>
>> This patch series is built on top of the Marc-AndrA(C) Lureau v3 series
>> "memfd: add sealing to hugetlb-backed memory":
>> http://lkml.kernel.org/r/20171107122800.25517-1-marcandre.lureau@redhat.com
> 
> Are you waiting for this series to be merged before resending as non-rfc?

Sort of.

I was hoping someone else would chime in on your series that adds file
sealing.  Since they both are touching the same code, there will be
a bit of 'patch management' involved.  One could argue that the config
dependency changes should go in before the file sealing code.  Actually,
it should have gone in before the hugetlbfs memfd_create code.  I'm not
sure if it matters too much right now.

I'm happy to do whatever people think is the right thing here.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
