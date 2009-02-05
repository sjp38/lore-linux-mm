Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ECA126B0047
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 15:02:17 -0500 (EST)
Date: Thu, 5 Feb 2009 14:02:14 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [Patch] mmu_notifiers destroyed by __mmu_notifier_release()
	retain extra mm_count.
Message-ID: <20090205200214.GN8577@sgi.com>
References: <20090205172303.GB8559@sgi.com> <alpine.DEB.1.10.0902051427280.13692@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0902051427280.13692@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, Andrea Arcangeli <andrea@qumranet.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 05, 2009 at 02:30:29PM -0500, Christoph Lameter wrote:
> The drop of the refcount needs to occur  after the last use of
> data in the mmstruct because mmdrop() may free the mmstruct.

Not this time.  We are being called from process termination and the
calling function is assured to hold one reference count.

We would also have to track how many callouts were made and then do
drops in a loop, but as stated above, I don't think it is needed.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
