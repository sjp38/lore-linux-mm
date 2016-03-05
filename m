Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 121116B0005
	for <linux-mm@kvack.org>; Sat,  5 Mar 2016 03:10:05 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p65so47090875wmp.1
        for <linux-mm@kvack.org>; Sat, 05 Mar 2016 00:10:05 -0800 (PST)
Received: from mx5-phx2.redhat.com (mx5-phx2.redhat.com. [209.132.183.37])
        by mx.google.com with ESMTPS id le8si7907881wjb.80.2016.03.05.00.10.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Mar 2016 00:10:03 -0800 (PST)
Date: Sat, 5 Mar 2016 03:09:50 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <983257005.5372143.1457165390827.JavaMail.zimbra@redhat.com>
In-Reply-To: <20160304133807.72ede1000b9bf0b846d2fb87@linux-foundation.org>
References: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com> <20160304133807.72ede1000b9bf0b846d2fb87@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: use EOPNOTSUPP in hugetlb sysctl handlers
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, mike kravetz <mike.kravetz@oracle.com>, hillf zj <hillf.zj@alibaba-inc.com>, kirill shutemov <kirill.shutemov@linux.intel.com>, dave hansen <dave.hansen@linux.intel.com>, paul gortmaker <paul.gortmaker@windriver.com>





----- Original Message -----
> From: "Andrew Morton" <akpm@linux-foundation.org>
> To: "Jan Stancek" <jstancek@redhat.com>
> Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, "mike kravetz"
> <mike.kravetz@oracle.com>, "hillf zj" <hillf.zj@alibaba-inc.com>, "kirill shutemov"
> <kirill.shutemov@linux.intel.com>, "dave hansen" <dave.hansen@linux.intel.com>, "paul gortmaker"
> <paul.gortmaker@windriver.com>
> Sent: Friday, 4 March, 2016 10:38:07 PM
> Subject: Re: [PATCH] mm/hugetlb: use EOPNOTSUPP in hugetlb sysctl handlers
> 
> On Thu,  3 Mar 2016 11:02:51 +0100 Jan Stancek <jstancek@redhat.com> wrote:
> 
> > Replace ENOTSUPP with EOPNOTSUPP. If hugepages are not supported,
> > this value is propagated to userspace. EOPNOTSUPP is part of uapi
> > and is widely supported by libc libraries.
> 
> hm, what is the actual user-visible effect of this change?  Does it fix
> some misbehaviour?
> 

It gives nicer message to user, rather than:
# cat /proc/sys/vm/nr_hugepages
cat: /proc/sys/vm/nr_hugepages: Unknown error 524

And also LTP's proc01 test was failing because this ret code (524)
was unexpected:
proc01      1  TFAIL  :  proc01.c:396: read failed: /proc/sys/vm/nr_hugepages: errno=???(524): Unknown error 524
proc01      2  TFAIL  :  proc01.c:396: read failed: /proc/sys/vm/nr_hugepages_mempolicy: errno=???(524): Unknown error 524
proc01      3  TFAIL  :  proc01.c:396: read failed: /proc/sys/vm/nr_overcommit_hugepages: errno=???(524): Unknown error 524

Regards,
Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
