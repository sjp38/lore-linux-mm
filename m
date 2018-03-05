Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD1766B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 17:55:58 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id k79so2384453ioi.6
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 14:55:58 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k1si6519796iti.36.2018.03.05.14.55.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 14:55:57 -0800 (PST)
Subject: Re: [PATCH v12 10/11] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <d8602e35e65c8bf6df1a85166bf181536a6f3664.1519227112.git.khalid.aziz@oracle.com>
 <a59ece97-ba1f-dfb1-bfc8-b44ffd8edbca@linux.intel.com>
 <84931753-9a84-8624-adb8-95bd05d87d56@oracle.com>
 <8b0edd2e-3e9b-1148-6309-38b61307a523@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <fabf221c-02e2-f968-d107-b028701dd837@oracle.com>
Date: Mon, 5 Mar 2018 15:55:23 -0700
MIME-Version: 1.0
In-Reply-To: <8b0edd2e-3e9b-1148-6309-38b61307a523@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, davem@davemloft.net, akpm@linux-foundation.org
Cc: corbet@lwn.net, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, rob.gardner@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, anthony.yznaga@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, allen.pais@oracle.com, tklauser@distanz.ch, shannon.nelson@oracle.com, vijay.ac.kumar@oracle.com, mhocko@suse.com, jack@suse.cz, punit.agrawal@arm.com, hughd@google.com, thomas.tai@oracle.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, minchan@kernel.org, imbrenda@linux.vnet.ibm.com, aarcange@redhat.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, gregkh@linuxfoundation.org, nagarathnam.muthusamy@oracle.com, linux@roeck-us.net, jane.chu@oracle.com, dan.j.williams@intel.com, jglisse@redhat.com, ktkhai@virtuozzo.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 03/05/2018 02:31 PM, Dave Hansen wrote:
> On 03/05/2018 01:14 PM, Khalid Aziz wrote:
>> Are you suggesting that vma returned by find_vma() could be split or
>> merged underneath me if I do not hold mmap_sem and thus make the flag
>> check invalid? If so, that is a good point.
> 
> This part does make me think that this code hasn't been tested very
> thoroughly.  Could you describe the testing that you have done?  For MPX
> and protection keys, I added something to tools/testing/selftests/x86,
> for instance.

This code was tested by a QA team and I ran a number of tests myself. I 
wrote tests to exercise all of the API, induce exceptions for 
invalid/illegal accesses and swapping was tested by allocating memory 
2-4 times of the system RAM available across 4-8 threads and 
reading/writing to this memory with ADI enabled. QA team wrote unit 
tests to test each API with valid and invalid combinations of arguments 
to the API. Stress tests that allocate and free ADI tagged memory were 
also run. A version of database server was created that uses ADI tagged 
memory for in-memory copy of database to test database workload. 100's 
of hours of tests were run across these tests over the last 1+ year 
these patches have been under review for. Cover letter includes 
description of most of these tests. This code has held up through all of 
these tests. It is entirely feasible some race conditions have not been 
uncovered yet, just like any other piece of software. Pulling this code 
into mainline kernel and having lot more people exercise this code will 
help shake out any remaining issues.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
