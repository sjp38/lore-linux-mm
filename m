Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4CFF16B00A9
	for <linux-mm@kvack.org>; Mon,  4 May 2009 12:25:39 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A991A82C354
	for <linux-mm@kvack.org>; Mon,  4 May 2009 12:37:46 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cpTkurw7nzCo for <linux-mm@kvack.org>;
	Mon,  4 May 2009 12:37:39 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8795782C314
	for <linux-mm@kvack.org>; Mon,  4 May 2009 12:37:26 -0400 (EDT)
Date: Mon, 4 May 2009 12:15:20 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] alloc_vmap_area: fix memory leak
In-Reply-To: <20090504163731.3675ea87@rwuerthntp>
Message-ID: <alpine.DEB.1.10.0905041214160.15574@qirst.com>
References: <20090504163731.3675ea87@rwuerthntp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ralph Wuerthner <ralphw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
