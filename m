Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8E5756B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 10:03:17 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A23D682C132
	for <linux-mm@kvack.org>; Tue,  5 May 2009 10:15:01 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oVpNCMhVKUAY for <linux-mm@kvack.org>;
	Tue,  5 May 2009 10:14:57 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 061D982C2EF
	for <linux-mm@kvack.org>; Tue,  5 May 2009 10:14:57 -0400 (EDT)
Date: Tue, 5 May 2009 09:47:22 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 3/3] mm: SLQB fix reclaim_state
In-Reply-To: <20090505091434.611071516@suse.de>
Message-ID: <alpine.DEB.1.10.0905050947100.11830@qirst.com>
References: <20090505091343.706910164@suse.de> <20090505091434.611071516@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: npiggin@suse.de
Cc: penberg@cs.helsinki.fi, stable@kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>



Acked-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
