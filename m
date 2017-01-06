Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 36FE66B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 12:02:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 5so1574588016pgi.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 09:02:11 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id m8si80243285pfi.25.2017.01.06.09.02.10
        for <linux-mm@kvack.org>;
        Fri, 06 Jan 2017 09:02:10 -0800 (PST)
Date: Fri, 06 Jan 2017 12:02:04 -0500 (EST)
Message-Id: <20170106.120204.927644401352332269.davem@davemloft.net>
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
From: David Miller <davem@davemloft.net>
In-Reply-To: <b761e7a9-6f64-e8cb-334a-a49528e95cdf@linux.intel.com>
References: <f33f2c3c-4ec5-423c-5d13-a4b9ab8f7a95@linux.intel.com>
	<cae91a3b-27f2-4008-539e-153d66fc03ae@oracle.com>
	<b761e7a9-6f64-e8cb-334a-a49528e95cdf@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@linux.intel.com
Cc: khalid.aziz@oracle.com, mhocko@kernel.org, rob.gardner@oracle.com, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org, hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 6 Jan 2017 08:55:03 -0800

> Actually, that reminds me...  How does your code interface with ksm?  Or
> is there no interaction needed since you're always working on virtual
> addresses?

This reminds me, I consider this feature potentially extremely useful for
kernel debugging.  So I would like to make sure we don't implement anything
in a way which would preclude that in the long term.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
