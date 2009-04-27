Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CB12A6B00C9
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:01:45 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id ACB6882C7EA
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:12:44 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id USMuszgHCfSA for <linux-mm@kvack.org>;
	Mon, 27 Apr 2009 17:12:40 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B852582C7EE
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:12:39 -0400 (EDT)
Date: Mon, 27 Apr 2009 16:51:05 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Replace the watermark-related union in struct zone with
 a watermark[] array
In-Reply-To: <20090427205400.GA23510@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0904271650280.1467@qirst.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-19-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com> <20090427170054.GE912@csn.ul.ie> <alpine.DEB.2.00.0904271340320.11972@chino.kir.corp.google.com>
 <20090427205400.GA23510@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009, Mel Gorman wrote:

> Would people prefer a getter/setter version?

I'd say leave it as is. It unifies the usage of the watermark array.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
