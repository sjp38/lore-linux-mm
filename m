Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 56C0E6B00B5
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 12:24:51 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AF5AF82C78D
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 12:36:14 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id m5Iv2kXuLcqj for <linux-mm@kvack.org>;
	Mon, 27 Apr 2009 12:36:14 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7D2BE82C794
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 12:36:08 -0400 (EDT)
Date: Mon, 27 Apr 2009 12:15:37 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Display 0 in meminfo for Committed_AS when value
 underflows
In-Reply-To: <1240848914.29485.52.camel@nimitz>
Message-ID: <alpine.DEB.1.10.0904271214580.31916@qirst.com>
References: <1240848620-16751-1-git-send-email-ebmunson@us.ibm.com> <1240848914.29485.52.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Eric B Munson <ebmunson@us.ibm.com>, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009, Dave Hansen wrote:

> Yeah, this is the right fix for now until we can iron out the base
> issues.  Eric, I think this may also be a candidate for -stable.

Is there any way you could use a ZVC there? Those already have the
underflow prevention logic. See include/linux/vmstat.h and mm/vmstat.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
