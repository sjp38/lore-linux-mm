Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D57D56B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 18:10:11 -0500 (EST)
Received: by pablj1 with SMTP id lj1so12107927pab.8
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 15:10:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bi15si18454610pdb.24.2015.03.02.15.10.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 15:10:10 -0800 (PST)
Date: Mon, 2 Mar 2015 15:10:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 0/3] hugetlbfs: optionally reserve all fs pages at mount
 time
Message-Id: <20150302151009.2ae58f4430f9f34b81533821@linux-foundation.org>
In-Reply-To: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Davidlohr Bueso <davidlohr@hp.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 27 Feb 2015 14:58:08 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> hugetlbfs allocates huge pages from the global pool as needed.  Even if
> the global pool contains a sufficient number pages for the filesystem
> size at mount time, those global pages could be grabbed for some other
> use.  As a result, filesystem huge page allocations may fail due to lack
> of pages.

Well OK, but why is this a sufficiently serious problem to justify
kernel changes?  Please provide enough info for others to be able
to understand the value of the change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
