Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 237FA6B0253
	for <linux-mm@kvack.org>; Sat, 20 Feb 2016 19:32:26 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id 9so145683064iom.1
        for <linux-mm@kvack.org>; Sat, 20 Feb 2016 16:32:26 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id a194si31594083ioe.5.2016.02.20.16.32.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 20 Feb 2016 16:32:23 -0800 (PST)
Message-ID: <1456014735.3136.26.camel@kernel.crashing.org>
Subject: Re: [PATCH V3 01/30] mm: Make vm_get_page_prot arch specific.
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 21 Feb 2016 11:32:15 +1100
In-Reply-To: <87egc9e83j.fsf@linux.vnet.ibm.com>
References: 
	<1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1455814254-10226-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20160218231546.GC2765@fergus.ozlabs.ibm.com>
	 <87egc9e83j.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Mackerras <paulus@ozlabs.org>
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Fri, 2016-02-19 at 08:10 +0530, Aneesh Kumar K.V wrote:
> 
> I was hoping to do that after this series. Something similar to
> 
> https://github.com/kvaneesh/linux/commit/0c2ac1328b678a6e187d1f2644a007204c59a047
> 
> "
> powerpc/mm: Add helper for page flag access in ioremap_at
> 
> Instead of using variables we use static inline which get patched during
> boot to either hash or radix version.
> "
> 
> That gives us a base to revert patches if we find issues with hash and
> still have a working radix base. So idea is to introduce radix with minimal
> changes to hash and then consolidate hash and radix as much as we can by
> updating hash linux format.

It's too much churn. In the end, that adds more risk than it removes and
makes it harder to follow what's going on.

I'd say first change hash to use the radix PTE format, then add radix.

Maybe just wait for Paulus patches ?

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
