Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 217706B004F
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 18:40:40 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 0/3] swsusp: shrink file cache first
Date: Sat, 7 Feb 2009 00:39:53 +0100
References: <E1LVFiv-00032p-HX@cmpxchg.org>
In-Reply-To: <E1LVFiv-00032p-HX@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902070039.54402.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: hannes@cmpxchg.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hello!

Hi Hannes,
 
> here are three patches that adjust the memory shrinking code used for
> suspend-to-disk.
> 
> The first two patches are cleanups only and can probably go in
> regardless of the third one.
> 
> The third patch changes the shrink_all_memory() logic to drop the file
> cache first before touching any mapped files and only then goes for
> anon pages.
> 
> The reason is that everything not shrunk before suspension has to go
> into the image and will be 'prefaulted' before the processes can
> resume and the system is usable again, so the image should be small
> and contain only pages that are likely to be used right after resume
> again.  And this in turn means that the inactive file cache is the
> best point to start decimating used memory.
> 
> Also, right now, subsequent faults of contiguously mapped files are
> likely to perform better than swapin (see
> http://kernelnewbies.org/KernelProjects/SwapoutClustering), so not
> only file cache is preferred over other pages, but file pages over
> anon pages in general.
> 
> Testing up to this point shows that the patch does what is intended,
> shrinking file cache in favor of anon pages.  But whether the idea is
> correct to begin with is a bit hard to quantify and I am still working
> on it, so RFC only.

Thanks a lot for the patches, I'll review them as soon as I can.

I've got them with broken headers, but that's not a big deal.

Best,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
