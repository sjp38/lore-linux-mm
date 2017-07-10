Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 205726B039F
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 02:01:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u62so105973188pgb.13
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 23:01:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 3si8334707plx.138.2017.07.09.23.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 23:01:20 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6A5xZ2H146766
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 02:01:19 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bjtx5gwny-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 02:01:19 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 10 Jul 2017 00:01:18 -0600
Date: Sun, 9 Jul 2017 23:01:01 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 34/38] procfs: display the protection-key number
 associated with a vma
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-35-git-send-email-linuxram@us.ibm.com>
 <1162ac6c-5e34-8a6c-fed2-6683d261352c@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1162ac6c-5e34-8a6c-fed2-6683d261352c@linux.vnet.ibm.com>
Message-Id: <20170710060101.GE5713@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Mon, Jul 10, 2017 at 08:37:28AM +0530, Anshuman Khandual wrote:
> On 07/06/2017 02:52 AM, Ram Pai wrote:
> > Display the pkey number associated with the vma in smaps of a task.
> > The key will be seen as below:
> > 
> > ProtectionKey: 0
> > 
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> > ---
> >  arch/powerpc/kernel/setup_64.c |    8 ++++++++
> >  1 files changed, 8 insertions(+), 0 deletions(-)
> > 
> > diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
> > index f35ff9d..ebc82b3 100644
> > --- a/arch/powerpc/kernel/setup_64.c
> > +++ b/arch/powerpc/kernel/setup_64.c
> > @@ -37,6 +37,7 @@
> >  #include <linux/memblock.h>
> >  #include <linux/memory.h>
> >  #include <linux/nmi.h>
> > +#include <linux/pkeys.h>
> >  
> >  #include <asm/io.h>
> >  #include <asm/kdump.h>
> > @@ -745,3 +746,10 @@ static int __init disable_hardlockup_detector(void)
> >  }
> >  early_initcall(disable_hardlockup_detector);
> >  #endif
> > +
> > +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> 
> Why not for X86 protection keys ?

hmm.. I dont understand the comment.


-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
