Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 104E76B0032
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 08:34:36 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so2234588pdb.11
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 05:34:35 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id kt6si12196812pbc.47.2015.01.18.05.34.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Jan 2015 05:34:34 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so33259449pab.12
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 05:34:33 -0800 (PST)
Message-ID: <54BBB664.6050402@gmail.com>
Date: Sun, 18 Jan 2015 22:34:28 +0900
From: Naoya Horiguchi <nao.horiguchi@gmail.com>
MIME-Version: 1.0
Subject: Re: [mmotm:master 105/365] arch/powerpc/mm/hugetlbpage.c:718:1: error:
 conflicting types for 'follow_huge_pud'
References: <201501171014.QrygxfEt%fengguang.wu@intel.com>
In-Reply-To: <201501171014.QrygxfEt%fengguang.wu@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Jan 17, 2015 at 10:59:14AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   59f7a5af1a6c9e19c6e5152f26548c494a2d7338
> commit: 3ecd42e200dc8afcdcea809b1546783e3dc271be [105/365] mm/hugetlb: reduce arch dependent code around follow_huge_*
> config: powerpc-pasemi_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 3ecd42e200dc8afcdcea809b1546783e3dc271be
>   # save the attached .config to linux build tree
>   make.cross ARCH=powerpc
>
> All error/warnings:
>
> >> arch/powerpc/mm/hugetlbpage.c:718:1: error: conflicting types for 'follow_huge_pud'
>     follow_huge_pud(struct mm_struct *mm, unsigned long address,
>     ^
>    In file included from arch/powerpc/mm/hugetlbpage.c:14:0:
>    include/linux/hugetlb.h:103:14: note: previous declaration of 'follow_huge_pud' was here
>     struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
>                  ^
>
> vim +/follow_huge_pud +718 arch/powerpc/mm/hugetlbpage.c
>
>    712	{
>    713		BUG();
>    714		return NULL;
>    715	}
>    716	
>    717	struct page *
>  > 718	follow_huge_pud(struct mm_struct *mm, unsigned long address,
>    719			pmd_t *pmd, int write)

Invalid argument type. Andrew, could you please fold the following diff?

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index b4c93e6b16e5..7e408bfc7948 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -716,7 +716,7 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
  
  struct page *
  follow_huge_pud(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+		pud_t *pud, int write)
  {
  	BUG();
  	return NULL;

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
