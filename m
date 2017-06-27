Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC5F36B02B4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:47:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 86so22937687pfq.11
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:47:19 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 205si1699982pgc.226.2017.06.27.03.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 03:47:19 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id f127so3851615pgc.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:47:18 -0700 (PDT)
Message-ID: <1498560384.7935.6.camel@gmail.com>
Subject: Re: [RFC v4 00/17] powerpc: Memory Protection Keys
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 27 Jun 2017 20:46:24 +1000
In-Reply-To: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Tue, 2017-06-27 at 03:11 -0700, Ram Pai wrote:
> Memory protection keys enable applications to protect its
> address space from inadvertent access or corruption from
> itself.
> 
> The overall idea:
> 
>  A process allocates a   key  and associates it with
>  a  address  range  within    its   address   space.
>  The process  than  can  dynamically  set read/write 
>  permissions on  the   key   without  involving  the 
>  kernel. Any  code that  violates   the  permissions
>  off the address space; as defined by its associated
>  key, will receive a segmentation fault.
> 
> This patch series enables the feature on PPC64 HPTE
> platform.
> 
> ISA3.0 section 5.7.13 describes the detailed specifications.
> 
> 
> Testing:
> 	This patch series has passed all the protection key
> 	tests available in  the selftests directory.
> 	The tests are updated to work on both x86 and powerpc.
> 
> version v4:
> 	(1) patches no more depend on the pte bits to program
> 		the hpte -- comment by Balbir
> 	(2) documentation updates
> 	(3) fixed a bug in the selftest.
> 	(4) unlike x86, powerpc lets signal handler change key
> 	    permission bits; the change will persist across
> 	    signal handler boundaries. Earlier we allowed
> 	    the signal handler to modify a field in the siginfo
> 	    structure which would than be used by the kernel
> 	    to program the key protection register (AMR)
>        		-- resolves a issue raised by Ben.
>     		"Calls to sys_swapcontext with a made-up context
> 	        will end up with a crap AMR if done by code who
> 	       	didn't know about that register".
> 	(5) these changes enable protection keys on 4k-page 
> 		kernel aswell.

I have not looked at the full series, but it seems cleaner than the original
one and the side-effect is that we can support 4k as well. Nice!

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
