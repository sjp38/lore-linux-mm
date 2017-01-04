Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4886B0069
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 18:57:29 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j15so348069807ioj.7
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 15:57:29 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w193si1312100itb.20.2017.01.04.15.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 15:57:28 -0800 (PST)
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>
 <6fcaab9f-40fb-fdfb-2c7e-bf21a862ab7c@linux.intel.com>
 <ae0b7d0b-54fa-fa93-3b50-d14ace1b16f5@oracle.com>
 <d234fb8b-965f-d966-46fe-965478fdf7cb@linux.intel.com>
 <8612e7db-97c5-f757-0aae-24c3acedbc29@oracle.com>
 <2c0502d0-20ef-44ac-db5b-7f651a70b978@linux.intel.com>
From: Rob Gardner <rob.gardner@oracle.com>
Message-ID: <dcf106d7-2747-3131-ac8b-5e3d85145f4a@oracle.com>
Date: Wed, 4 Jan 2017 15:56:58 -0800
MIME-Version: 1.0
In-Reply-To: <2c0502d0-20ef-44ac-db5b-7f651a70b978@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 01/04/2017 03:49 PM, Dave Hansen wrote:
> On 01/04/2017 03:44 PM, Rob Gardner wrote:
>> On 01/04/2017 03:40 PM, Dave Hansen wrote:
>>> On 01/04/2017 03:35 PM, Rob Gardner wrote:
>>>> Tags are not cleared at all when memory is freed, but rather, lazily
>>>> (and automatically) cleared when memory is allocated.
>>> What does "allocated" mean in this context?  Physical or virtual? What
>>> does this do, for instance?
>> The first time a virtual page is touched by a process after the malloc,
>> the kernel does clear_user_page() or something similar, which zeroes the
>> memory. At the same time, the memory tags are cleared.
> OK, so the tags can't survive a MADV_FREE.  That's definitely something
> for apps to understand that use MADV_FREE as a substitute for memset().
> It also means that tags can't be set for physically unallocated memory.
>
> Neither of those are deal killers, but it would be nice to document it.
>
> How does this all work with large pages?

It all works completely with large pages.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
