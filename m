Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id B5D226B02AB
	for <linux-mm@kvack.org>; Fri,  3 May 2013 09:00:27 -0400 (EDT)
Message-ID: <1367586018.4389.67.camel@pasglop>
Subject: Re: [PATCH -V7 02/10] powerpc/THP: Implement transparent hugepages
 for ppc64
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 03 May 2013 23:00:18 +1000
In-Reply-To: <20130503115428.GW13041@truffula.fritz.box>
References: 
	<1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1367178711-8232-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20130503045201.GO13041@truffula.fritz.box>
	 <1367569143.4389.56.camel@pasglop>
	 <20130503115428.GW13041@truffula.fritz.box>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, paulus@samba.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Fri, 2013-05-03 at 21:54 +1000, David Gibson wrote:
> > _PAGE_BUSY is more like a read lock. It means it's being hashed, so what
> > is not stable is _PAGE_HASHPTE, slot index, _ACCESSED and _DIRTY. The
> > rest is stable and usually is what pmd_same looks at (though I have a
> > small doubt vs. _ACCESSED and _DIRTY but at least x86 doesn't care since
> > they are updated by HW).
> 
> Ok.  It still seems very odd to me that _PAGE_BUSY would be in the THP
> version of _PAGE_HASHPTE, but not the normal one.

Oh I agree, we should be consistent and it shouldn't be there, I was just
correcting some other aspect of your statement :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
