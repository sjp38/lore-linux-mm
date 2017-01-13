Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E56626B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 12:36:58 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so139506122pfx.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 09:36:58 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i23si13316470pll.72.2017.01.13.09.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 09:36:57 -0800 (PST)
Subject: Re: [PATCH v4 0/4] Application Data Integrity feature introduced by
 SPARC M7
References: <cover.1483999591.git.khalid.aziz@oracle.com>
 <621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
 <f70cd704-f486-ed5c-7961-b71278fc8f9a@oracle.com>
 <11d20dac-2c0f-6e9a-7f98-3839c749adb6@linux.intel.com>
 <4978715f-e5e8-824e-3804-597eaa0beb95@oracle.com>
 <558ad70b-4b19-3a78-038a-b12dc7af8585@linux.intel.com>
 <5d28f71e-1ad2-b2f9-1174-ea4eb6399d23@oracle.com>
 <a7ab2796-d777-df7b-2372-2d76f2906ead@linux.intel.com>
 <b480fdcc-e08a-eea7-9bac-12bc236422c6@oracle.com>
 <b0a6341d-fb85-9f50-4803-304f3e28b4ab@linux.intel.com>
 <ae1662fa-4e51-d92d-7f19-403c92406194@oracle.com>
 <ee959bf4-73db-f9bb-c697-20b47dd8d55f@oracle.com>
 <9aa6d94d-0a80-7397-5cd2-c04a39cbaf82@oracle.com>
 <d20972cf-e9b8-b7fd-00e4-75bddb90b990@oracle.com>
 <216f7527-3b8a-9c2f-4631-dda30bda03b4@linux.intel.com>
From: Rob Gardner <rob.gardner@oracle.com>
Message-ID: <815b1871-5353-deb9-2091-0803bec029b7@oracle.com>
Date: Fri, 13 Jan 2017 10:36:26 -0700
MIME-Version: 1.0
In-Reply-To: <216f7527-3b8a-9c2f-4631-dda30bda03b4@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On 01/13/2017 09:08 AM, Dave Hansen wrote:
> On 01/13/2017 07:29 AM, Rob Gardner wrote:
>> so perhaps ADI should simply be disallowed for memory mapped to
>> files, and this particular complication can be avoided. Thoughts?
> What's a "file" from your perspective?
>
> In Linux, shared memory is a file.  hugetlbfs is done with files.  Many
> databases mmap() their data into their address space.

Of course I meant a traditional file is the DOS sense, ie, data stored 
on something magnetic. ;) But it doesn't really matter because I am just 
trying to envision a use case for any of the mmap scenarios.

For instance a very persuasive use case for ADI is to 'color' malloc 
memory, freed malloc memory, and malloc's metadata with different ADI 
version tags so as to catch buffer overflows, underflows, use-after-free 
and use-after-realloc type scenarios. What is an equally compelling or 
even mildly interesting use case for ADI in shared memory and file mmap 
situations? Maybe you could mmap a file and immediately tag the entire 
thing with some version, thus disallowing all access to it, and then 
hand out access a chunk at a time. And then?

Rob



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
