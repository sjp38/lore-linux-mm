Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E68AB6B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 03:27:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g7so26334286pgp.1
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 00:27:08 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id k64si1685674pge.371.2017.07.07.00.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 00:27:08 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id d193so3082029pgc.2
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 00:27:07 -0700 (PDT)
Message-ID: <1499412358.23251.7.camel@gmail.com>
Subject: Re: [RFC v5 01/38] powerpc: Free up four 64K PTE bits in 4K backed
 HPTE pages
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 07 Jul 2017 17:25:58 +1000
In-Reply-To: <1499289735-14220-2-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
	 <1499289735-14220-2-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Wed, 2017-07-05 at 14:21 -0700, Ram Pai wrote:
> Rearrange 64K PTE bits to  free  up  bits 3, 4, 5  and  6,
> in the 4K backed HPTE pages.These bits continue to be used
> for 64K backed HPTE pages in this patch, but will be freed
> up in the next patch. The  bit  numbers are big-endian  as
> defined in the ISA3.0
> 
> The patch does the following change to the 4k htpe backed
> 64K PTE's format.
>

The diagrams make the patch much easier to understand, thanks!

<snip>
 
> NOTE:even though bits 3, 4, 5, 6, 7 are  not  used  when
> the  64K  PTE is backed by 4k HPTE,  they continue to be
> used  if  the  PTE  gets  backed  by 64k HPTE.  The next
> patch will decouple that aswell, and truely  release the
> bits.
>

<snip>

Balbir Singh. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
