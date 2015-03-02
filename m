Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C78EA6B006E
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 18:10:25 -0500 (EST)
Received: by padet14 with SMTP id et14so21732716pad.0
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 15:10:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n4si4519928pdn.170.2015.03.02.15.10.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 15:10:24 -0800 (PST)
Date: Mon, 2 Mar 2015 15:10:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 2/3] hugetlbfs: coordinate global and subpool reserve
 accounting
Message-Id: <20150302151023.e40dd1c6a9bf3d29cb6b657c@linux-foundation.org>
In-Reply-To: <1425077893-18366-4-git-send-email-mike.kravetz@oracle.com>
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
	<1425077893-18366-4-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Davidlohr Bueso <davidlohr@hp.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 27 Feb 2015 14:58:11 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> If the pages for a subpool are reserved, then the reservations have
> already been accounted for in the global pool.  Therefore, when
> requesting a new reservation (such as for a mapping) for the subpool
> do not count again in global pool.  However, when actually allocating
> a page for the subpool decrement global reserve count to correspond to
> with decrement in global free pages.

The last sentence made my brain hurt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
