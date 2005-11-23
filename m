From: "Yi Feng" <yifeng@cs.umass.edu>
Subject: RE: [patch] vmsig: notify user applications of virtual memory events via real-time signals
Date: Wed, 23 Nov 2005 11:30:09 -0500
Message-ID: <000401c5f04b$2f482d80$0b00a8c0@louise>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
In-Reply-To: <Pine.LNX.4.63.0511230810380.5075@cuia.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Rik van Riel' <riel@redhat.com>
Cc: 'Rohit Seth' <rohit.seth@intel.com>, 'Emery Berger' <emery@cs.umass.edu>, linux-mm@kvack.org, 'Andrew Morton' <akpm@osdl.org>, 'Matthew Hertz' <hertzm@canisius.edu>
List-ID: <linux-mm.kvack.org>

> -----Original Message-----
> From: Rik van Riel [mailto:riel@redhat.com]
> Sent: Wednesday, November 23, 2005 8:11 AM
> To: Yi Feng
> Cc: 'Rohit Seth'; 'Emery Berger'; linux-mm@kvack.org; 'Andrew Morton';
> 'Matthew Hertz'
> Subject: RE: [patch] vmsig: notify user applications of virtual memory
> events via real-time signals
> 
> On Wed, 23 Nov 2005, Yi Feng wrote:
> 
> > When the application receives this notification and starts to process
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

If the application can make the page completely useless, then it can use
MADV_DONTNEED. However, for some applications (e.g. our Bookmarking
Collection) the processed page may still contain useful data and can't be
simply discarded. And because it was chosen as an eviction victim before the
processing, it's deemed cold by the kernel, so we send it to swap with
MADV_RELINQUISH.


Yi Feng


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
