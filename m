Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DF86A6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:42:40 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 03D6B3040E3
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:48:44 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 54f6oPDmyZbd for <linux-mm@kvack.org>;
	Tue, 10 Mar 2009 13:48:43 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 903FF3040F7
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:48:23 -0400 (EDT)
Date: Tue, 10 Mar 2009 13:40:02 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: PROBLEM: kernel BUG at mm/slab.c:3002!
In-Reply-To: <49B68450.9000505@hp.com>
Message-ID: <alpine.DEB.1.10.0903101339210.9350@qirst.com>
References: <49B68450.9000505@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Alan D. Brunelle" <Alan.Brunelle@hp.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Oh nice memory corruption. May have something to do with the vmap work by
Nick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
