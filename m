Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 43C546B0258
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 15:37:26 -0500 (EST)
Received: by mail-yk0-f175.google.com with SMTP id u9so373338ykd.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 12:37:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y188si12347711ybb.85.2016.03.02.12.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 12:37:24 -0800 (PST)
Subject: Re: [PATCH] sparc64: Add support for Application Data Integrity (ADI)
References: <201603030434.DgIxwogV%fengguang.wu@intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <56D74EE2.6080106@oracle.com>
Date: Wed, 2 Mar 2016 13:36:50 -0700
MIME-Version: 1.0
In-Reply-To: <201603030434.DgIxwogV%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net
Cc: corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/02/2016 01:26 PM, kbuild test robot wrote:
> Hi Khalid,
>
> [auto build test ERROR on sparc/master]
> [also build test ERROR on v4.5-rc6]
> [cannot apply to next-20160302]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
>
> url:    https://github.com/0day-ci/linux/commits/Khalid-Aziz/sparc64-Add-support-for-Application-Data-Integrity-ADI/20160303-025709
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc.git master
> config: sparc64-allnoconfig (attached as .config)
> reproduce:
>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=sparc64
>
> All errors (new ones prefixed by >>):
>
>     arch/sparc/kernel/process_64.c: In function 'disable_sparc_adi':
>>> arch/sparc/kernel/process_64.c:961:6: error: implicit declaration of function 'vma_policy' [-Werror=implicit-function-declaration]
>           vma_policy(vma), vma->vm_userfaultfd_ctx);
>           ^
>     arch/sparc/kernel/process_64.c:959:10: error: passing argument 9 of 'vma_merge' makes pointer from integer without a cast [-Werror]
>        prev = vma_merge(mm, prev, addr, end, vma->vm_flags,
>               ^
>     In file included from arch/sparc/kernel/process_64.c:18:0:
>     include/linux/mm.h:1922:31: note: expected 'struct mempolicy *' but argument is of type 'int'
>      extern struct vm_area_struct *vma_merge(struct mm_struct *,
>                                    ^

Not sure why it built without errors on my system. I will #include 
<linux/mempolicy.h> and send updated patch.

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
