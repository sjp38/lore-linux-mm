Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5FB6B0255
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 23:24:24 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 124so3796465pfg.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 20:24:24 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id kw7si1758264pab.74.2016.03.07.20.24.23
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 20:24:23 -0800 (PST)
Date: Mon, 07 Mar 2016 23:24:18 -0500 (EST)
Message-Id: <20160307.232418.1734056188463866385.davem@davemloft.net>
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
From: David Miller <davem@davemloft.net>
In-Reply-To: <56DE1AF1.40107@oracle.com>
References: <56DDC776.3040003@oracle.com>
	<20160307.141600.1873883635480850431.davem@davemloft.net>
	<56DE1AF1.40107@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: rob.gardner@oracle.com, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Mon, 7 Mar 2016 17:21:05 -0700

> Can we enable ADI support for swappable pages in a subsequent update
> after the core functionality is stable on mlock'd pages?

I already said no.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
