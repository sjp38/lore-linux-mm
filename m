Date: Wed, 16 Mar 2005 10:10:07 -0500
From: Martin Hicks <mort@sgi.com>
Subject: Re: [PATCH] Move code to isolate LRU pages into separate function
Message-ID: <20050316151007.GG19113@localhost>
References: <20050314214941.GP3286@localhost> <20050315195452.GE19113@localhost> <20050315223717.2a0f80e6.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050315223717.2a0f80e6.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 15, 2005 at 10:37:17PM -0800, Andrew Morton wrote:
> >  This version fixes that and also allows passing in a NULL scanned
> >  argument if you don't care how many pages were scanned.
> > 
> 
> But neither caller passes in a NULL argument.

I was playing around with another function, and I really didn't care how
many pages were scanned.  I just thought that it seemed like a silly
requirement to pass a variable in for scanned if you didn't care.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
