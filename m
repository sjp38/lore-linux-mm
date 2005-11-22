Content-class: urn:content-classes:message
Subject: RE: [patch] vmsig: notify user applications of virtual memory events via real-time signals
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Date: Tue, 22 Nov 2005 16:53:22 -0500
Message-ID: <B061F5ED2860D9439AE34EE5C141938C090CDE@zor.ads.cs.umass.edu>
From: "Emery Berger" <emery@cs.umass.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, Yi Feng <yifeng@cs.umass.edu>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Matthew Hertz <hertzm@canisius.edu>
List-ID: <linux-mm.kvack.org>

> That seems pretty high overhead.  I wonder if it wouldn't work
> similarly well for the kernel to simply notify the registrered
> apps that memory is running low and they should garbage collect
> _something_, without caring which pages.

Actually, it's quite important that the application know exactly which
page is being evicted, in order that it be "bookmarked". We found that
this particular aspect of the garbage collection algorithm was crucial
(it's in the paper).

Best,
-- emery

--
Emery Berger
Assistant Professor
Dept. of Computer Science
University of Massachusetts, Amherst
www.cs.umass.edu/~emery
 

> -----Original Message-----
> From: Rik van Riel [mailto:riel@redhat.com]
> Sent: Tuesday, November 22, 2005 4:45 PM
> To: Yi Feng
> Cc: linux-mm@kvack.org; 'Andrew Morton'; Emery Berger; 'Matthew Hertz'
> Subject: Re: [patch] vmsig: notify user applications of virtual memory
> events via real-time signals
> 
> On Tue, 22 Nov 2005, Yi Feng wrote:
> 
> > The user application can therefore maintain the residence
information of
> > all its pages and cooperate with the kernel under memory pressure.
> 
> That seems pretty high overhead.  I wonder if it wouldn't work
> similarly well for the kernel to simply notify the registrered
> apps that memory is running low and they should garbage collect
> _something_, without caring which pages.
> 
> Then the apps can "shoot holes" in their memory use by calling
> madvise with MADV_DONTNEED on the pages the application judges
> to be the least likely ones to be used again.
> 
> OTOH, maybe keeping state for each page is low enough overhead.
> I will have to read your patch to figure out the details ;)
> 
> --
> All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
