Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 084056B006E
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 17:13:36 -0500 (EST)
Received: by padet14 with SMTP id et14so30895105pad.11
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 14:13:35 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id x8si16774926pdk.135.2015.03.06.14.13.34
        for <linux-mm@kvack.org>;
        Fri, 06 Mar 2015 14:13:35 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/4] hugetlbfs: optionally reserve all fs pages at mount time
References: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
Date: Fri, 06 Mar 2015 14:13:33 -0800
In-Reply-To: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com> (Mike
	Kravetz's message of "Tue, 3 Mar 2015 17:21:42 -0800")
Message-ID: <87lhj9ai5u.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Mike Kravetz <mike.kravetz@oracle.com> writes:

> hugetlbfs allocates huge pages from the global pool as needed.  Even if
> the global pool contains a sufficient number pages for the filesystem
> size at mount time, those global pages could be grabbed for some other
> use.  As a result, filesystem huge page allocations may fail due to lack
> of pages.


What's the difference of this new option to simply doing

mount -t hugetlbfs none /huge
echo XXX > /proc/sys/vm/nr_hugepages

?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
