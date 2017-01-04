Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6ECD06B0253
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 18:50:30 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a190so1347736207pgc.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 15:50:30 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 92si73973316plc.147.2017.01.04.15.50.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 15:50:29 -0800 (PST)
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>
 <f7985965-3e33-4352-0ffb-97a5407f7acc@linux.intel.com>
 <f58e46c2-5ae6-8cff-3fde-f9ee1729fd71@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <c483a325-d914-222f-f7ab-b3c19c5ff77b@linux.intel.com>
Date: Wed, 4 Jan 2017 15:50:29 -0800
MIME-Version: 1.0
In-Reply-To: <f58e46c2-5ae6-8cff-3fde-f9ee1729fd71@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 01/04/2017 03:46 PM, Khalid Aziz wrote:
>> It would also be really nice to see a high-level breakdown explaining
>> what you had to modify, especially since this affects all of the system
>> calls that take a PROT_* argument.  The sample code is nice, but it's no
>> substitute for writing it down.
> 
> I will expand the explanation in Documentation/sparc/adi.txt.

I think (partially) duplicating that in a cover letter would also be
nice.  The documentation is a bit buried in the 1,000 lines of code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
