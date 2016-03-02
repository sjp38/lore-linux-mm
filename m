Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 505136B0256
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 15:27:05 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj10so232866pad.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 12:27:05 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id n62si60199391pfa.183.2016.03.02.12.27.04
        for <linux-mm@kvack.org>;
        Wed, 02 Mar 2016 12:27:04 -0800 (PST)
Date: Thu, 3 Mar 2016 04:26:20 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] sparc64: Add support for Application Data Integrity (ADI)
Message-ID: <201603030434.DgIxwogV%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="sm4nu43k4a2Rpi4c"
Content-Disposition: inline
In-Reply-To: <1456944849-21869-1-git-send-email-khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: kbuild-all@01.org, davem@davemloft.net, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Khalid,

[auto build test ERROR on sparc/master]
[also build test ERROR on v4.5-rc6]
[cannot apply to next-20160302]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Khalid-Aziz/sparc64-Add-support-for-Application-Data-Integrity-ADI/20160303-025709
base:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc.git master
config: sparc64-allnoconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sparc64 

All errors (new ones prefixed by >>):

   arch/sparc/kernel/process_64.c: In function 'disable_sparc_adi':
>> arch/sparc/kernel/process_64.c:961:6: error: implicit declaration of function 'vma_policy' [-Werror=implicit-function-declaration]
         vma_policy(vma), vma->vm_userfaultfd_ctx);
         ^
   arch/sparc/kernel/process_64.c:959:10: error: passing argument 9 of 'vma_merge' makes pointer from integer without a cast [-Werror]
      prev = vma_merge(mm, prev, addr, end, vma->vm_flags,
             ^
   In file included from arch/sparc/kernel/process_64.c:18:0:
   include/linux/mm.h:1922:31: note: expected 'struct mempolicy *' but argument is of type 'int'
    extern struct vm_area_struct *vma_merge(struct mm_struct *,
                                  ^
   cc1: all warnings being treated as errors

vim +/vma_policy +961 arch/sparc/kernel/process_64.c

   955			/* Update the ADI info in vma and check if this vma can
   956			 * be merged with adjacent ones
   957			 */
   958			pgoff = vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT);
   959			prev = vma_merge(mm, prev, addr, end, vma->vm_flags,
   960					 vma->anon_vma, vma->vm_file, pgoff,
 > 961					 vma_policy(vma), vma->vm_userfaultfd_ctx);
   962			if (prev)
   963				vma = prev;
   964	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--sm4nu43k4a2Rpi4c
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--sm4nu43k4a2Rpi4c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
