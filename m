Date: Tue, 22 Nov 2005 16:45:16 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch] vmsig: notify user applications of virtual memory events
 via real-time signals
In-Reply-To: <000001c5efa6$ff513990$9728010a@redmond.corp.microsoft.com>
Message-ID: <Pine.LNX.4.63.0511221643000.14848@cuia.boston.redhat.com>
References: <000001c5efa6$ff513990$9728010a@redmond.corp.microsoft.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yi Feng <yifeng@cs.umass.edu>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@osdl.org>, 'Emery Berger' <emery@cs.umass.edu>, 'Matthew Hertz' <hertzm@canisius.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Nov 2005, Yi Feng wrote:

> The user application can therefore maintain the residence information of 
> all its pages and cooperate with the kernel under memory pressure.

That seems pretty high overhead.  I wonder if it wouldn't work
similarly well for the kernel to simply notify the registrered
apps that memory is running low and they should garbage collect
_something_, without caring which pages.

Then the apps can "shoot holes" in their memory use by calling
madvise with MADV_DONTNEED on the pages the application judges
to be the least likely ones to be used again.

OTOH, maybe keeping state for each page is low enough overhead.
I will have to read your patch to figure out the details ;)

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
