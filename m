Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 763AC6B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 17:18:10 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fl4so85645170pad.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 14:18:10 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id rr7si6062548pab.223.2016.03.07.14.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 14:18:09 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id 124so88032275pfg.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 14:18:09 -0800 (PST)
Date: Mon, 7 Mar 2016 14:18:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/hugetlb: use EOPNOTSUPP in hugetlb sysctl handlers
In-Reply-To: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com>
Message-ID: <alpine.DEB.2.10.1603071417570.18158@chino.kir.corp.google.com>
References: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, paul.gortmaker@windriver.com

On Thu, 3 Mar 2016, Jan Stancek wrote:

> Replace ENOTSUPP with EOPNOTSUPP. If hugepages are not supported,
> this value is propagated to userspace. EOPNOTSUPP is part of uapi
> and is widely supported by libc libraries.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
