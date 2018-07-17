Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2B706B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 19:57:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x9-v6so1999390qto.18
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 16:57:04 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f24-v6si1912633qkm.396.2018.07.17.16.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 16:57:01 -0700 (PDT)
Subject: Re: mmap with huge page
References: <115606142.5883850.1531854314452.ref@mail.yahoo.com>
 <115606142.5883850.1531854314452@mail.yahoo.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <3b40325e-a75e-017d-920e-83e090153621@oracle.com>
Date: Tue, 17 Jul 2018 16:56:53 -0700
MIME-Version: 1.0
In-Reply-To: <115606142.5883850.1531854314452@mail.yahoo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Frank <david_frank95@yahoo.com>, Kernelnewbies <kernelnewbies@kernelnewbies.org>, Linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/17/2018 12:05 PM, David Frank wrote:
> Hi,
> According to the instruction, I have to mount a huge directory to hugetlbfs and create file in the huge directory to use the mmap huge page feature. But the issue is that, the files in the huge directory takes up the huge pages configured through
> vm.nr_hugepages =
> 
> even the files are not used.
> 
> When the total size of the files in the huge directory = vm.nr_hugepages * huge page size, then mmap would fail with 'can not allocate memory' if the file to be  mapped is in the huge dir or the call has HUGEPAGETLB flag.
> 
> Basically, I have to move the files off of the huge directory to free up huge pages.
> 
> Am I missing anything here?
> 

No, that is working as designed.

hugetlbfs filesystems are generally pre-allocated with nr_hugepages
huge pages.  That is the upper limit of huge pages available.  You can
use overcommit/surplus pages to try and exceed the limit, but that
comes with a whole set of potential issues.

If you have not done so already, please see Documentation/vm/hugetlbpage.txt
in the kernel source tree.
-- 
Mike Kravetz
