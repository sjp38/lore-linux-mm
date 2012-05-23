Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 1FA2C6B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 19:17:52 -0400 (EDT)
Date: Wed, 23 May 2012 16:17:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg/hugetlb: Add failcnt support for hugetlb
 extension
Message-Id: <20120523161750.f0e22c5b.akpm@linux-foundation.org>
In-Reply-To: <1337686991-26418-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1337686991-26418-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz

On Tue, 22 May 2012 17:13:11 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Expose the failcnt details to userspace similar to memory and memsw.

Why?

In general, it is best not to add any new userspace interfaces at all. 
We will do so, if there are good reasons.  But you've provided no reason
at all.

>  include/linux/hugetlb.h |    2 +-
>  mm/memcontrol.c         |   40 ++++++++++++++++++++++++++--------------

Documentation/cgroups/memory.txt needs updating also.  You modify the
user insterface, you modify documentation - this should be automatic
for all of us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
