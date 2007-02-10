Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l1AMip0K081082
	for <linux-mm@kvack.org>; Sat, 10 Feb 2007 22:44:51 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1AMipw41732714
	for <linux-mm@kvack.org>; Sat, 10 Feb 2007 22:44:51 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1AMipfk022797
	for <linux-mm@kvack.org>; Sat, 10 Feb 2007 22:44:51 GMT
Subject: Re: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try
	3)
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <20070210001844.21921.48605.sendpatchset@linux.site>
References: <20070210001844.21921.48605.sendpatchset@linux.site>
Content-Type: text/plain
Date: Sat, 10 Feb 2007 23:44:55 +0100
Message-Id: <1171147495.31563.5.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2007-02-10 at 03:31 +0100, Nick Piggin wrote:
> SetNewPageUptodate does not do the S390 page_test_and_clear_dirty, so
> I'd like to make sure that's OK.

An I/O operation on s390 will set the dirty bit for a page. That is the
reason to have SetPageUptodate clear the per page dirty bit when the
page is made uptodate the first time. Otherwise we end up writing each
page back to its backing device at least once. If SetNewPageUptodate is
used on new anonymous pages exclusively I don't see a problem in
omitting the page_test_clear_dirty.

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
