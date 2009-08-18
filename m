Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 957CC6B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 10:18:52 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E272782C6AE
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 10:19:06 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 316DNv5S2jlw for <linux-mm@kvack.org>;
	Tue, 18 Aug 2009 10:19:02 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4219C82C69E
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 10:19:02 -0400 (EDT)
Date: Tue, 18 Aug 2009 10:18:48 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] page-allocator: Move pcp static fields for high and
 batch off-pcp and onto the zone
In-Reply-To: <1250594162-17322-4-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0908181015420.32284@gentwo.org>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie> <1250594162-17322-4-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


This will increase the cache footprint for the hot code path. Could these
new variable be moved next to zone fields that are already in use there?
The pageset array is used f.e.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
