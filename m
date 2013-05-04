Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 7F6166B02A7
	for <linux-mm@kvack.org>; Sat,  4 May 2013 17:39:29 -0400 (EDT)
Message-ID: <1367703559.11982.1.camel@pasglop>
Subject: Re: [PATCH -V7 02/10] powerpc/THP: Implement transparent hugepages
 for ppc64
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 05 May 2013 07:39:19 +1000
In-Reply-To: <87a9oa4kx0.fsf@linux.vnet.ibm.com>
References: 
	<1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1367178711-8232-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20130503045201.GO13041@truffula.fritz.box>
	 <87a9oa4kx0.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: David Gibson <dwg@au1.ibm.com>, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Sun, 2013-05-05 at 00:44 +0530, Aneesh Kumar K.V wrote:
> 
> We may want to retain some of these because of the assert we want to add
> for locking. PTE related functions expect ptl to be locked. PMD related
> functions expect mm->page_table_lock to be locked.

In this case have a single inline commmon function __something called
by two different wrappers.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
