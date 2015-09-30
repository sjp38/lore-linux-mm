Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id E279C6B0264
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 17:56:45 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so24327701qkc.3
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 14:56:45 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v107si2722079qgd.76.2015.09.30.14.56.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 14:56:45 -0700 (PDT)
Subject: Re: [PATCH 00/12] userfaultfd non-x86 and selftest updates for 4.2.0+
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <560C5A83.9080103@oracle.com>
Date: Wed, 30 Sep 2015 14:56:19 -0700
MIME-Version: 1.0
In-Reply-To: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

On 09/08/2015 01:43 PM, Andrea Arcangeli wrote:
> Here are some pending updates for userfaultfd mostly to the self test,
> the rest are cleanups.

I have a potential use case for userfualtfd.  So, I started experimenting
with the self test code.  I replaced the posix_memalign() calls to allocate
area_src and area_dst with mmap().  mmap(MAP_PRIVATE | MAP_ANONYMOUS) works
as expected.  However, mmap(MAP_SHARED | MAP_ANONYMOUS) causes the test to
fail without any errros from the userfaultfd APIs.

--------------------
running userfaultfd
--------------------
nr_pages: 32768, nr_pages_per_cpu: 8192
bounces: 31, mode: rnd racing ver poll, page_nr 31523 wrong count 0 1

I would expect some type of error from the ioctl() that registers the
range, or perhaps the poll/copy code?  Just curious about the expected
behavior.

FYI - My use case is for hugetlbfs.  I would like a mechanism to catch all
new huge page allocations as a result of page faults.  I have some very
rough code to extend userfualtfd and add the required functionality to
hugetlbfs.  Still working on it.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
