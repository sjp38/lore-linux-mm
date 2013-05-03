Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id BD7966B02FC
	for <linux-mm@kvack.org>; Fri,  3 May 2013 17:54:13 -0400 (EDT)
Message-ID: <1367618044.4389.117.camel@pasglop>
Subject: Re: [PATCH -V7 09/10] powerpc: Optimize hugepage invalidate
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 04 May 2013 07:54:04 +1000
In-Reply-To: <87fvy351gc.fsf@linux.vnet.ibm.com>
References: 
	<1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1367178711-8232-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20130503052846.GU13041@truffula.fritz.box>
	 <87fvy351gc.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: David Gibson <dwg@au1.ibm.com>, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Sat, 2013-05-04 at 00:35 +0530, Aneesh Kumar K.V wrote:
> 
> if the firmware doesn't support lockless TLBIE, we need to do locking
> at the guest side. pSeries_lpar_flush_hash_range does that.

We don't "need" to ... it's an optimization because by experience the FW
locking was horrible (and the HW locking is too).

Beware however that the hash routines can take a lock too on
"native" (instead of pHyp)...

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
