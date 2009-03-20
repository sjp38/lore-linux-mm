Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 195C86B003D
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:04:36 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8917682C9D0
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:13:50 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id C8ReBAYkWQfL for <linux-mm@kvack.org>;
	Fri, 20 Mar 2009 11:13:44 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5F8EC82C9D4
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:13:38 -0400 (EDT)
Date: Fri, 20 Mar 2009 11:04:11 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 07/25] Check in advance if the zonelist needs additional
 filtering
In-Reply-To: <1237543392-11797-8-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903201104000.3740@qirst.com>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie> <1237543392-11797-8-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Reviewed-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
