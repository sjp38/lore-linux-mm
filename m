Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3D4E66B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 20:40:48 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3E24D82C250
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 20:47:12 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id kvUczC0t9RuS for <linux-mm@kvack.org>;
	Tue,  3 Nov 2009 20:47:06 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 037F1700065
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 13:13:48 -0500 (EST)
Date: Tue, 3 Nov 2009 13:06:37 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 7/14] cpumask: avoid deprecated function in mm/slab.c
In-Reply-To: <200911031457.39368.rusty@rustcorp.com.au>
Message-ID: <alpine.DEB.1.10.0911031306050.32136@V090114053VZO-1>
References: <200911031457.39368.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009, Rusty Russell wrote
>
> These days we use cpumask_empty() which takes a pointer.

Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
