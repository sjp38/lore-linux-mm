Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8FD066B00A2
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 03:17:49 -0500 (EST)
Date: Sun, 1 Mar 2009 19:17:44 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090301081744.GI26138@disturbed>
References: <20090225093629.GD22785@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090225093629.GD22785@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2009 at 10:36:29AM +0100, Nick Piggin wrote:
> I need this in fsblock because I am working to ensure filesystem metadata
> can be correctly allocated and refcounted. This means that page cleaning
> should not require memory allocation (to be really robust).

Which, unfortunately, is just a dream for any filesystem that uses
delayed allocation. i.e. they have to walk the free space trees
which may need to be read from disk and therefore require memory
to succeed....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
