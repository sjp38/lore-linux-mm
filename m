Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 36DB06B025D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 17:01:46 -0400 (EDT)
Date: Fri, 22 Jun 2012 14:01:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V2 1/2] hugetlb: Move all the in use pages to active
 list
Message-Id: <20120622140143.6cf0551d.akpm@linux-foundation.org>
In-Reply-To: <1339756263-20378-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339756263-20378-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz

On Fri, 15 Jun 2012 16:01:02 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> When we fail to allocate pages from the reserve pool, hugetlb
> do try to allocate huge pages using alloc_buddy_huge_page.
> Add these to the active list. We also need to add the huge
> page we allocate when we soft offline the oldpage to active
> list.

When fixing a bug, please describe the end-user-visible effects of that bug.

Fully.  Every time.  No exceptions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
