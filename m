Content-class: urn:content-classes:message
Subject: RE: [patch] vmsig: notify user applications of virtual memory events via real-time signals
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Date: Wed, 23 Nov 2005 08:33:18 -0500
Message-ID: <B061F5ED2860D9439AE34EE5C141938C090CF0@zor.ads.cs.umass.edu>
From: "Emery Berger" <emery@cs.umass.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, Yi Feng <yifeng@cs.umass.edu>
Cc: Rohit Seth <rohit.seth@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Matthew Hertz <hertzm@canisius.edu>
List-ID: <linux-mm.kvack.org>

> Would it be better for the application to completely vacate
> the page, so MADV_DONTNEED can be used instead, and swap IO
> can be avoided ?

Yes, but under severe memory pressure, it is not possible.

-- emery

--
Emery Berger
Assistant Professor
Dept. of Computer Science
University of Massachusetts, Amherst
www.cs.umass.edu/~emery


> -----Original Message-----
> From: Rik van Riel [mailto:riel@redhat.com]
> Sent: Wednesday, November 23, 2005 8:11 AM
> To: Yi Feng
> Cc: 'Rohit Seth'; Emery Berger; linux-mm@kvack.org; 'Andrew Morton';
> 'Matthew Hertz'
> Subject: RE: [patch] vmsig: notify user applications of virtual memory
> events via real-time signals
> 
> On Wed, 23 Nov 2005, Yi Feng wrote:
> 
> > When the application receives this notification and starts to
process
> this
> > page, this page will stay in core (possibly for a fairly long time)
> because
> > it's been touched again. That's why we also added
> madvise(MADV_RELINQUISH)
> > to explicitly send the page to swap after the processing.
> 
> Would it be better for the application to completely vacate
> the page, so MADV_DONTNEED can be used instead, and swap IO
> can be avoided ?
> 
> --
> All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
