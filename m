Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 34AC96B0038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 14:32:53 -0400 (EDT)
Received: by igr7 with SMTP id 7so128851825igr.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 11:32:53 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id el7si2742281pdb.190.2015.07.28.11.32.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 11:32:52 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so73693034pac.3
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 11:32:52 -0700 (PDT)
Date: Tue, 28 Jul 2015 11:32:48 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: hugetlb pages not accounted for in rss
Message-ID: <20150728183248.GB1406@Sligo.logfs.org>
References: <55B6BE37.3010804@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55B6BE37.3010804@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon, Jul 27, 2015 at 04:26:47PM -0700, Mike Kravetz wrote:
> I started looking at the hugetlb self tests.  The test hugetlbfstest
> expects hugetlb pages to be accounted for in rss.  However, there is
> no code in the kernel to do this accounting.
> 
> It looks like there was an effort to add the accounting back in 2013.
> The test program made it into tree, but the accounting code did not.

My apologies.  Upstream work always gets axed first when I run out of
time - which happens more often than not.

> The easiest way to resolve this issue would be to remove the test and
> perhaps document that hugetlb pages are not accounted for in rss.
> However, it does seem like a big oversight that hugetlb pages are not
> accounted for in rss.  From a quick scan of the code it appears THP
> pages are properly accounted for.
> 
> Thoughts?

Unsurprisingly I agree that hugepages should count towards rss.  Keeping
the test in keeps us honest.  Actually fixing the issue would make us
honest and correct.

Increasingly we have tiny processes (by rss) that actually consume large
fractions of total memory.  Makes rss somewhat useless as a measure of
anything.

Jorn

--
Consensus is no proof!
-- John Naisbitt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
