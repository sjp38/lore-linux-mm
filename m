Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 568A46B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 06:23:15 -0400 (EDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 30 Jul 2012 11:23:13 +0100
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6UAN9vV872544
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 11:23:10 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6UAN5V5012494
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 04:23:09 -0600
Date: Mon, 30 Jul 2012 12:23:05 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC PATCH v5 12/19] memory-hotplug: introduce new function
 arch_remove_memory()
Message-ID: <20120730102305.GB3631@osiris.boeblingen.de.ibm.com>
References: <50126B83.3050201@cn.fujitsu.com>
 <50126E2F.8010301@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50126E2F.8010301@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

On Fri, Jul 27, 2012 at 06:32:15PM +0800, Wen Congyang wrote:
> We don't call __add_pages() directly in the function add_memory()
> because some other architecture related things need to be done
> before or after calling __add_pages(). So we should introduce
> a new function arch_remove_memory() to revert the things
> done in arch_add_memory().
> 
> Note: the function for s390 is not implemented(I don't know how to
> implement it for s390).

There is no hardware or firmware interface which could trigger a
hot memory remove on s390. So there is nothing that needs to be
implemented.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
