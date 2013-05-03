Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id DBBAD6B02C3
	for <linux-mm@kvack.org>; Fri,  3 May 2013 04:19:13 -0400 (EDT)
Message-ID: <1367569143.4389.56.camel@pasglop>
Subject: Re: [PATCH -V7 02/10] powerpc/THP: Implement transparent hugepages
 for ppc64
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 03 May 2013 18:19:03 +1000
In-Reply-To: <20130503045201.GO13041@truffula.fritz.box>
References: 
	<1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1367178711-8232-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20130503045201.GO13041@truffula.fritz.box>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Fri, 2013-05-03 at 14:52 +1000, David Gibson wrote:
> Here, specifically, the fact that PAGE_BUSY is in PAGE_THP_HPTEFLAGS
> is likely to be bad.  If the page is busy, it's in the middle of
> update so can't stably be considered the same as anything.

_PAGE_BUSY is more like a read lock. It means it's being hashed, so what
is not stable is _PAGE_HASHPTE, slot index, _ACCESSED and _DIRTY. The
rest is stable and usually is what pmd_same looks at (though I have a
small doubt vs. _ACCESSED and _DIRTY but at least x86 doesn't care since
they are updated by HW).

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
