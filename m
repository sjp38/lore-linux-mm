Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACC96B0036
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 23:37:22 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so2935568pdi.33
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 20:37:22 -0800 (PST)
Received: from psmtp.com ([74.125.245.102])
        by mx.google.com with SMTP id ot3si2931461pac.195.2013.11.19.20.37.19
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 20:37:20 -0800 (PST)
Date: Wed, 20 Nov 2013 15:36:36 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V2 4/5] powerpc: mm: Only check for _PAGE_PRESENT in
 set_pte/pmd functions
Message-ID: <20131120043636.GC5281@iris.ozlabs.ibm.com>
References: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1384766893-10189-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384766893-10189-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Mon, Nov 18, 2013 at 02:58:12PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We want to make sure we don't use these function when updating a pte
> or pmd entry that have a valid hpte entry, because these functions
> don't invalidate them. So limit the check to _PAGE_PRESENT bit.
> Numafault core changes use these functions for updating _PAGE_NUMA bits.
> That should be ok because when _PAGE_NUMA is set we can be sure that
> hpte entries are not present.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Paul Mackerras <paulus@samba.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
