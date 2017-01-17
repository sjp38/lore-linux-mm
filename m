Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 806446B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:42:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 5so111317944pgi.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 20:42:19 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id b128si23615007pgc.336.2017.01.16.20.42.18
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 20:42:18 -0800 (PST)
Date: Mon, 16 Jan 2017 23:42:13 -0500 (EST)
Message-Id: <20170116.234213.651609572218128435.davem@davemloft.net>
Subject: Re: [PATCH v4 0/4] Application Data Integrity feature introduced
 by SPARC M7
From: David Miller <davem@davemloft.net>
In-Reply-To: <621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
References: <cover.1483999591.git.khalid.aziz@oracle.com>
	<621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@linux.intel.com
Cc: khalid.aziz@oracle.com, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org, hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 11 Jan 2017 08:33:30 -0800

> Is there a cost in the hardware associated with doing this "ADI
> checking"?  For instance, instead of having this new mprotect()
> interface, why not just always set TTE.mcd on all PTEs?

If we did this then for every page mapped into userspace we'd have
to explicitly set all of the tags to zero, otherwise we'd get TAG
mismatch exceptions.

That would be like clearing the every mapped anonymous page twice, or
worse.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
