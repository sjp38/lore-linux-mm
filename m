Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1E8626B004F
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:35:57 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9A4AC82C39D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:38:35 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UZVhjldWO576 for <linux-mm@kvack.org>;
	Thu,  5 Feb 2009 14:38:31 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6EC2282C381
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:38:28 -0500 (EST)
Date: Thu, 5 Feb 2009 14:30:29 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [Patch] mmu_notifiers destroyed by __mmu_notifier_release()
 retain extra mm_count.
In-Reply-To: <20090205172303.GB8559@sgi.com>
Message-ID: <alpine.DEB.1.10.0902051427280.13692@qirst.com>
References: <20090205172303.GB8559@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@qumranet.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The drop of the refcount needs to occur  after the last use of
data in the mmstruct because mmdrop() may free the mmstruct.

Place it after the synchronize_rcu?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
