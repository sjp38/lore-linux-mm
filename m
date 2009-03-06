Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5471E6B008A
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 16:42:02 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 40C0F82D879
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 16:47:40 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4rKtM1SdHtCl for <linux-mm@kvack.org>;
	Fri,  6 Mar 2009 16:47:35 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1BB5F82D875
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 16:45:12 -0500 (EST)
Date: Fri, 6 Mar 2009 16:29:23 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: possible bug in find_get_pages
In-Reply-To: <20090306211336.GA5981@linux.intel.com>
Message-ID: <alpine.DEB.1.10.0903061628270.20398@qirst.com>
References: <20090306192625.GA3267@linux.intel.com> <alpine.DEB.1.10.0903061426190.20182@qirst.com> <20090306211336.GA5981@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: mark gross <mgross@linux.intel.com>
Cc: linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 6 Mar 2009, mark gross wrote:

> Still form a static read of the code that goto repeat raises
> eyebrows as why would anyone expect to get anything different from
> radix_page_deref_slot calling it again with the same arguments?

Another processor may be updating the same structure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
