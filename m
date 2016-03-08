Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id EB983828DF
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 22:01:11 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id 124so2419316pfg.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 19:01:11 -0800 (PST)
Received: from out21.biz.mail.alibaba.com (out21.biz.mail.alibaba.com. [205.204.114.132])
        by mx.google.com with ESMTP id t13si1216505pas.225.2016.03.07.19.01.09
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 19:01:11 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com> <alpine.DEB.2.10.1603071417570.18158@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1603071417570.18158@chino.kir.corp.google.com>
Subject: Re: [PATCH] mm/hugetlb: use EOPNOTSUPP in hugetlb sysctl handlers
Date: Tue, 08 Mar 2016 11:00:52 +0800
Message-ID: <049701d178e6$ba604ea0$2f20ebe0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'David Rientjes' <rientjes@google.com>, 'Jan Stancek' <jstancek@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, paul.gortmaker@windriver.com

> 
> On Thu, 3 Mar 2016, Jan Stancek wrote:
> 
> > Replace ENOTSUPP with EOPNOTSUPP. If hugepages are not supported,
> > this value is propagated to userspace. EOPNOTSUPP is part of uapi
> > and is widely supported by libc libraries.
> >
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Mike Kravetz <mike.kravetz@oracle.com>
> > Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Cc: Dave Hansen <dave.hansen@linux.intel.com>
> > Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> >
> > Signed-off-by: Jan Stancek <jstancek@redhat.com>
> 
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
