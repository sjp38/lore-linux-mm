Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 217F66B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 19:04:03 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so6596532wml.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 16:04:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wf8si167337wjb.122.2016.03.07.16.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 16:04:02 -0800 (PST)
Date: Mon, 7 Mar 2016 16:03:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: use EOPNOTSUPP in hugetlb sysctl handlers
Message-Id: <20160307160359.c8cde2e7cc4a52234f212c0d@linux-foundation.org>
In-Reply-To: <983257005.5372143.1457165390827.JavaMail.zimbra@redhat.com>
References: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com>
	<20160304133807.72ede1000b9bf0b846d2fb87@linux-foundation.org>
	<983257005.5372143.1457165390827.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, mike kravetz <mike.kravetz@oracle.com>, hillf zj <hillf.zj@alibaba-inc.com>, kirill shutemov <kirill.shutemov@linux.intel.com>, dave hansen <dave.hansen@linux.intel.com>, paul gortmaker <paul.gortmaker@windriver.com>

On Sat, 5 Mar 2016 03:09:50 -0500 (EST) Jan Stancek <jstancek@redhat.com> wrote:

> > > Replace ENOTSUPP with EOPNOTSUPP. If hugepages are not supported,
> > > this value is propagated to userspace. EOPNOTSUPP is part of uapi
> > > and is widely supported by libc libraries.
> > 
> > hm, what is the actual user-visible effect of this change?  Does it fix
> > some misbehaviour?
> > 
> 
> It gives nicer message to user, rather than:
> # cat /proc/sys/vm/nr_hugepages
> cat: /proc/sys/vm/nr_hugepages: Unknown error 524
> 
> And also LTP's proc01 test was failing because this ret code (524)
> was unexpected:
> proc01      1  TFAIL  :  proc01.c:396: read failed: /proc/sys/vm/nr_hugepages: errno=???(524): Unknown error 524
> proc01      2  TFAIL  :  proc01.c:396: read failed: /proc/sys/vm/nr_hugepages_mempolicy: errno=???(524): Unknown error 524
> proc01      3  TFAIL  :  proc01.c:396: read failed: /proc/sys/vm/nr_overcommit_hugepages: errno=???(524): Unknown error 524
> 

Ah, OK, thanks.  "Unknown error 524" is rather rude.  I'll queue this
for 4.5.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
