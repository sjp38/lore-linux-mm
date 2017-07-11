Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 971316B050B
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 10:52:51 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v88so518254wrb.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:52:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a193si1962122wmd.151.2017.07.11.07.52.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 07:52:49 -0700 (PDT)
Date: Tue, 11 Jul 2017 16:52:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v5 00/38] powerpc: Memory Protection Keys
Message-ID: <20170711145246.GA11917@dhcp22.suse.cz>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Wed 05-07-17 14:21:37, Ram Pai wrote:
> Memory protection keys enable applications to protect its
> address space from inadvertent access or corruption from
> itself.
> 
> The overall idea:
> 
>  A process allocates a   key  and associates it with
>  an  address  range  within    its   address   space.
>  The process  then  can  dynamically  set read/write 
>  permissions on  the   key   without  involving  the 
>  kernel. Any  code that  violates   the  permissions
>  of  the address space; as defined by its associated
>  key, will receive a segmentation fault.
> 
> This patch series enables the feature on PPC64 HPTE
> platform.
> 
> ISA3.0 section 5.7.13 describes the detailed specifications.

Could you describe the highlevel design of this feature in the cover
letter. I have tried to get some idea from the patchset but it was
really far from trivial. Patches are not very well split up (many
helpers are added without their users etc..). 

> 
> Testing:
> 	This patch series has passed all the protection key
> 	tests available in  the selftests directory.
> 	The tests are updated to work on both x86 and powerpc.
> 
> version v5:
> 	(1) reverted back to the old design -- store the 
> 	    key in the pte, instead of bypassing it.
> 	    The v4 design slowed down the hash page path.

This surprised me a lot but I couldn't find the respective code. Why do
you need to store anything in the pte? My understanding of PKEYs is that
the setup and teardown should be very cheap and so no page tables have
to updated. Or do I just misunderstand what you wrote here?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
