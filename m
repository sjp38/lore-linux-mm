Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 483E36B00E9
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 11:48:54 -0500 (EST)
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20090225093629.GD22785@wotan.suse.de>
References: <20090225093629.GD22785@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 25 Feb 2009 11:48:44 -0500
Message-Id: <1235580524.32346.5.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-02-25 at 10:36 +0100, Nick Piggin wrote:
> I want to have the page be protected by page lock between page_mkwrite
> notification to the filesystem, and the actual setting of the page
> dirty. Do this by holding the page lock over page_mkwrite, and keep it
> held until after set_page_dirty.

Are any of the filesystems ordering the journal lock outside the page
lock?  I thought ocfs2 and ext4 were either doing this or discussing it.
If they are, this will make fsblock hard to use for them.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
