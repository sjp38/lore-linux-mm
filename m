Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2E17C6B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 16:38:11 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n186so8598273wmn.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 13:38:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m194si1000161wmg.82.2016.03.04.13.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 13:38:10 -0800 (PST)
Date: Fri, 4 Mar 2016 13:38:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: use EOPNOTSUPP in hugetlb sysctl handlers
Message-Id: <20160304133807.72ede1000b9bf0b846d2fb87@linux-foundation.org>
In-Reply-To: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com>
References: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, paul.gortmaker@windriver.com

On Thu,  3 Mar 2016 11:02:51 +0100 Jan Stancek <jstancek@redhat.com> wrote:

> Replace ENOTSUPP with EOPNOTSUPP. If hugepages are not supported,
> this value is propagated to userspace. EOPNOTSUPP is part of uapi
> and is widely supported by libc libraries.

hm, what is the actual user-visible effect of this change?  Does it fix
some misbehaviour?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
