Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 576356B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:46:20 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 174CF82C62F
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:50:16 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id L6U0itoI9VQC for <linux-mm@kvack.org>;
	Fri,  9 Oct 2009 09:50:11 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CC2D082C66A
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:49:48 -0400 (EDT)
Date: Fri, 9 Oct 2009 09:39:31 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: move inc_zone_page_state(NR_ISOLATED) to just
 isolated place
In-Reply-To: <20091009100527.1284.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0910090939060.26484@gentwo.org>
References: <20091009100527.1284.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>



Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
