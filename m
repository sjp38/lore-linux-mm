Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB77D6B026B
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 11:25:32 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n21so357454599qka.4
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:25:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k95si40668005qkh.19.2017.01.06.08.25.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 08:25:32 -0800 (PST)
Date: Fri, 06 Jan 2017 11:25:25 -0500 (EST)
Message-Id: <20170106.112525.2194459503197293118.davem@redhat.com>
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
From: David Miller <davem@redhat.com>
In-Reply-To: <cae91a3b-27f2-4008-539e-153d66fc03ae@oracle.com>
References: <ac86aa55-964d-56a1-1381-c208de78b24e@oracle.com>
	<f33f2c3c-4ec5-423c-5d13-a4b9ab8f7a95@linux.intel.com>
	<cae91a3b-27f2-4008-539e-153d66fc03ae@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: dave.hansen@linux.intel.com, mhocko@kernel.org, rob.gardner@oracle.com, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org, hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Fri, 6 Jan 2017 09:22:13 -0700

> On 01/06/2017 08:36 AM, Dave Hansen wrote:
>> On 01/06/2017 07:32 AM, Khalid Aziz wrote:
>>> I agree with you on simplicity first. Subpage granularity is complex,
>>> but the architecture allows for subpage granularity. Maybe the right
>>> approach is to support this at page granularity first for swappable
>>> pages and then expand to subpage granularity in a subsequent patch?
>>> Pages locked in memory can already use subpage granularity with my
>>> patch.
>>
>> What do you mean by "locked in memory"?  mlock()'d memory can still be
>> migrated around and still requires "swap" ptes, for instance.
> 
> You are right. Page migration can invalidate subpage granularity even
> for locked pages. Is it possible to use cpusets to keep a task and its
> memory locked on a single node? Just wondering if there are limited
> cases where subpage granularity could work without supporting subpage
> granularity for tags in swap. It still sounds like the right thing to
> do is to get a reliable implementation in place with page size
> granularity and then add the complexity of subpage granularity.

It sounds to me, in all of this, that if the kernel manages the
movement of the pages, it thus must handle making sure the tags move
around with that page as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
