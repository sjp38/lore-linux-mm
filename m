Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8A2B46B0123
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 14:39:35 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A804782D7C2
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 14:45:10 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0U8MM5It+m9F for <linux-mm@kvack.org>;
	Fri,  6 Mar 2009 14:45:06 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D15C982D7B6
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 14:45:02 -0500 (EST)
Date: Fri, 6 Mar 2009 14:28:50 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: possible bug in find_get_pages
In-Reply-To: <20090306192625.GA3267@linux.intel.com>
Message-ID: <alpine.DEB.1.10.0903061426190.20182@qirst.com>
References: <20090306192625.GA3267@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: mark gross <mgross@linux.intel.com>
Cc: linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 6 Mar 2009, mark gross wrote:

> It seems that page->_count == 0 at some point on some overnight runs
> with locks the system into a tight loop from the repeat: and a goto
> repeat in find_get_pages.

A page with ref count zero should not be in any mapping. If the page is in
a mapping then the page is used. Therefore the refcount should be > 0.

If there is a page with zero refcount and its in a mapping then something
erroneously decreased the refcount.

Nick wrote the code so I CCed him.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
