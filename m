Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 22B316B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 11:46:30 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0DD0982C267
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 11:48:21 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id HwpV9Veqq-rG for <linux-mm@kvack.org>;
	Wed, 28 Jan 2009 11:48:20 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9457082C336
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 11:48:07 -0500 (EST)
Date: Wed, 28 Jan 2009 11:42:36 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] migration: migrate_vmas should check "vma"
In-Reply-To: <20090128162619.2205befd.nishimura@mxp.nes.nec.co.jp>
Message-ID: <alpine.DEB.1.10.0901281140540.7765@qirst.com>
References: <20090128162619.2205befd.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jan 2009, Daisuke Nishimura wrote:

> migrate_vmas() should check "vma" not "vma->vm_next" for for-loop condition.

The loop condition is checked before vma = vma->vm_next. So the last
iteration of the loop will now be run with vma = NULL?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
