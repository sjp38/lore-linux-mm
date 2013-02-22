Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 704F76B0007
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 00:38:54 -0500 (EST)
Date: Fri, 22 Feb 2013 16:03:27 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [RFC PATCH -V2 02/21] powerpc: Save DAR and DSISR in pt_regs on
 MCE
Message-ID: <20130222050327.GB6139@drongo>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1361465248-10867-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361465248-10867-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, Feb 21, 2013 at 10:17:09PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We were not saving DAR and DSISR on MCE. Save then and also print the values
> along with exception details in xmon.

The one reservation I have about this is that xmon will now be
printing bogus values on 32-bit and embedded processors.  However, it
seems 32-bit doesn't set regs->dar on a DSI (300) interrupt either.
So:

Acked-by: Paul Mackerras <paulus@samba.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
