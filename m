Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 3E3256B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 03:43:04 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 11 Oct 2012 08:43:02 +0100
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9B7gr2j56426722
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 07:42:53 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9B7gxuX007078
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 01:42:59 -0600
Date: Thu, 11 Oct 2012 09:42:57 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
Message-ID: <20121011094257.61a9a460@mschwide>
In-Reply-To: <alpine.LSU.2.00.1210101402310.1939@eggly.anvils>
References: <1349108796-32161-1-git-send-email-jack@suse.cz>
	<alpine.LSU.2.00.1210082029190.2237@eggly.anvils>
	<20121009162107.GE15790@quack.suse.cz>
	<alpine.LSU.2.00.1210091824390.30802@eggly.anvils>
	<20121010085524.GA32581@quack.suse.cz>
	<alpine.LSU.2.00.1210101402310.1939@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org

On Wed, 10 Oct 2012 14:28:32 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> But perhaps these machines aren't much into heavy swapping.  Now, 
> if Martin would send me a nice little zSeries netbook for Xmas,
> I could then test that end of it myself ;)

Are you sure about that? The electricity cost alone for such a beast
is quite high ;-)

> I've just arrived at the conclusion that page migration does _not_
> have a problem with transferring the dirty storage key: I had been
> thinking that your testing might stumble on that issue, and need a
> further patch, but I'll explain in other mail why now I think not.

That is good to know, one problem less on the list.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
