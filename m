Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2E37E6B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 00:03:02 -0500 (EST)
Date: Wed, 5 Jan 2011 00:02:35 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1831207094.134996.1294203755749.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20110104175630.GC3190@mgebm.net>
Subject: Re: [PATCH] hugetlb: remove overcommit sysfs for 1GB pages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm <linux-mm@kvack.org>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>


> There are a couple of issues here: first, I think the overcommit value being overwritten
> is a bug and this needs to be addressed and fixed before we cover it by removing the sysfs
> file.
I have a reproducer mentioned in another thread. The trick is to run this command at the end,

echo "" >/proc/sys/vm/nr_overcommit_hugepages

> Second, will it be easier for userspace to work with some huge page
> sizes having the
> overcommit file and others not or making the kernel hand EINVAL back
> when nr_overcommit is
> is changed for an unsupported page size?
I am not sure if it is normal for sysfs and procfs entries to return EINVAL. At least,
nr_hugepages files are not capable to return EINVAL for 1GB pages case as well. It merely
keep the value intact when trying to change it.

I was also wondering if it is possible to modify those files' permission based on the page size,
but it looks like hard to implement since sysctl files permission is pretty much static.

> Finally, this is a problem for more than 1GB pages on x86_64. It is
> true for all pages >
> 1 << MAX_ORDER. Once the overcommit bug is fixed and the second issue
> is answered, the
> solution that is used (either EINVAL or no overcommit file) needs to
> happen for all cases
> where it applies, not just the 1GB case.
OK, good point.

Thanks.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
