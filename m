Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id BD6976B0007
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 14:28:33 -0500 (EST)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 5 Feb 2013 19:27:16 -0000
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r15JSKbq13566046
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 19:28:21 GMT
Received: from d06av09.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r15JST3K000543
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 12:28:29 -0700
Date: Tue, 5 Feb 2013 11:28:21 -0800
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] software dirty bits for s390
Message-ID: <20130205112821.0e35b241@mschwide>
In-Reply-To: <1360087925-8456-2-git-send-email-schwidefsky@de.ibm.com>
References: <1360087925-8456-1-git-send-email-schwidefsky@de.ibm.com>
	<1360087925-8456-2-git-send-email-schwidefsky@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-s390@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

On Tue,  5 Feb 2013 10:12:04 -0800
Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> Greetings,
> 
> good news, I got performance results for a selected set of workloads
> with my software dirty bit patch (thanks Christian!). We found no
> downsides to the software dirty bits, and a substantial improvement
> in CPU utilization for the FIO test with mostly read mappings.
> 
> The patch can now go upstream.

Grumpf, 0000-cover-letter.patch~ in the outgoing directory.
Please ignore.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
