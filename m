Date: Wed, 23 Nov 2005 08:11:12 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: RE: [patch] vmsig: notify user applications of virtual memory events
 via real-time signals
In-Reply-To: <000001c5efea$da132280$0b00a8c0@louise>
Message-ID: <Pine.LNX.4.63.0511230810380.5075@cuia.boston.redhat.com>
References: <000001c5efea$da132280$0b00a8c0@louise>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yi Feng <yifeng@cs.umass.edu>
Cc: 'Rohit Seth' <rohit.seth@intel.com>, 'Emery Berger' <emery@cs.umass.edu>, linux-mm@kvack.org, 'Andrew Morton' <akpm@osdl.org>, 'Matthew Hertz' <hertzm@canisius.edu>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Nov 2005, Yi Feng wrote:

> When the application receives this notification and starts to process this
> page, this page will stay in core (possibly for a fairly long time) because
> it's been touched again. That's why we also added madvise(MADV_RELINQUISH)
> to explicitly send the page to swap after the processing.

Would it be better for the application to completely vacate
the page, so MADV_DONTNEED can be used instead, and swap IO
can be avoided ?

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
