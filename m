Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A9B326B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:35:19 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EC43B82D0ED
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:55:26 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UMLaYBPCMP0m for <linux-mm@kvack.org>;
	Tue, 24 Mar 2009 11:55:26 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2BF2482D10B
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:55:22 -0400 (EDT)
Date: Tue, 24 Mar 2009 11:44:48 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: why my systems never cache more than ~900 MB?
In-Reply-To: <49C8FDD4.7070900@wpkg.org>
Message-ID: <alpine.DEB.1.10.0903241142510.13587@qirst.com>
References: <49C89CE0.2090103@wpkg.org> <200903250220.45575.nickpiggin@yahoo.com.au> <49C8FDD4.7070900@wpkg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tomasz Chmielewski <mangoo@wpkg.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Mar 2009, Tomasz Chmielewski wrote:

> Nick Piggin schrieb:
> Does not help me, as what interests me here on these machines is mainly
> caching block device data; they are iSCSI targets and access block devices
> directly.

You can run a 64 bit kernel on those machines. 64 bit kernels can use
32 bit userspace without a problem. Just install an additional kernel and
try booting your existing setup with it.

> What split should I choose to enable blockdev mapping on the whole memory on
> 32 bit system with 3 or 4 GB RAM? Is it possible with 4 GB RAM at all?

A 64 bit kernel will do the trick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
