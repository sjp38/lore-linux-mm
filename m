Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35CEE2803D0
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 17:45:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a2so9192277pfj.2
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 14:45:01 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id q125si938676pfb.342.2017.09.05.14.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 14:44:59 -0700 (PDT)
Date: Tue, 05 Sep 2017 14:44:56 -0700 (PDT)
Message-Id: <20170905.144456.431070706382873486.davem@davemloft.net>
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
From: David Miller <davem@davemloft.net>
In-Reply-To: <20170904162530.GA21781@amd>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
	<3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
	<20170904162530.GA21781@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pavel@ucw.cz
Cc: khalid.aziz@oracle.com, dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

From: Pavel Machek <pavel@ucw.cz>
Date: Mon, 4 Sep 2017 18:25:30 +0200

> Will gcc be able to compile code that uses these automatically? That
> does not sound easy to me. Can libc automatically use this in malloc()
> to prevent accessing freed data when buffers are overrun?
> 
> Is this for benefit of JITs?

Anything that can control mappings and the virtual address used to
access memory can use ADI.

malloc() is of course one such case.  It can map memory with ADI
enabled, and return buffer addresses to malloc() callers with the
proper virtual address bits set to satisfy the ADI key checks.

And by induction anything using malloc() for it's memory allocation
gets ADI protection as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
