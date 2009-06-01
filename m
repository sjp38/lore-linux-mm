Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8466E5F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:33:39 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5974C82C923
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 13:43:59 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id iBSQh7czdbFI for <linux-mm@kvack.org>;
	Mon,  1 Jun 2009 13:43:59 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E273282C90A
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 13:43:56 -0400 (EDT)
Date: Mon, 1 Jun 2009 13:29:06 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Warn if we run out of swap space
In-Reply-To: <4A23FF89.2060603@redhat.com>
Message-ID: <alpine.DEB.1.10.0906011328410.3921@gentwo.org>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <4A23FF89.2060603@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Jun 2009, Avi Kivity wrote:

> We really should have a machine readable channel for this sort of information,
> so it can be plumbed to a userspace notification bubble the user can ignore.

Good idea. Create an event for udev?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
