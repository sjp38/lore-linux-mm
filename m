Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD1D6B0008
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 20:05:31 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id c26so304581qtj.14
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 17:05:31 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x20si3921838qkg.89.2018.02.23.17.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 17:05:30 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1O14WxQ011479
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 20:05:29 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gatw5wtub-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 20:05:29 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 24 Feb 2018 01:05:26 -0000
Date: Fri, 23 Feb 2018 17:05:11 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v12 1/3] mm, powerpc, x86: define VM_PKEY_BITx bits if
 CONFIG_ARCH_HAS_PKEYS is enabled
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1519257138-23797-2-git-send-email-linuxram@us.ibm.com>
 <201802231528.snWZIspR%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201802231528.snWZIspR%fengguang.wu@intel.com>
Message-Id: <20180224010511.GK5559@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

On Fri, Feb 23, 2018 at 03:11:45PM +0800, kbuild test robot wrote:
> Hi Ram,
> 
> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.16-rc2 next-20180222]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
>         chmod +x ~/bin/make.cross
...snip..
>         # save the attached .config to linux build tree
>         make.cross ARCH=powerpc 
> 
> Note: the linux-review/Ram-Pai/mm-x86-powerpc-Enhancements-to-Memory-Protection-Keys/20180223-042743 HEAD c5692bca45543c242ffca15c811923e4c548ed19 builds fine.
>       It only hurts bisectibility.

oops, it broke git-bisect on powerpc :-(
The following change will fix it. This should nail it down.

diff --git a/arch/powerpc/include/asm/pkeys.h
b/arch/powerpc/include/asm/pkeys.h
index 0409c80..0b3b669 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -25,6 +25,7 @@
 # define VM_PKEY_BIT1  VM_HIGH_ARCH_1
 # define VM_PKEY_BIT2  VM_HIGH_ARCH_2
 # define VM_PKEY_BIT3  VM_HIGH_ARCH_3
 # define VM_PKEY_BIT4  VM_HIGH_ARCH_4
+#elif !defined(VM_PKEY_BIT4)
+# define VM_PKEY_BIT4  VM_HIGH_ARCH_4
#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
