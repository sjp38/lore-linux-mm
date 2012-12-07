Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id A65FD6B0098
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 17:44:30 -0500 (EST)
Date: Fri, 7 Dec 2012 14:44:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Debugging: Keep track of page owners
Message-Id: <20121207144428.98b3eaf4.akpm@linux-foundation.org>
In-Reply-To: <50C26FA7.9010000@linux.vnet.ibm.com>
References: <20121207212417.FAD8DAED@kernel.stglabs.ibm.com>
	<20121207142614.428b8a54.akpm@linux-foundation.org>
	<50C26FA7.9010000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On Fri, 07 Dec 2012 14:37:27 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On 12/07/2012 02:26 PM, Andrew Morton wrote:\
> > I have cunningly divined the intention of your update and have queued
> > the below incremental.  The change to
> > pagetypeinfo_showmixedcount_print() was a surprise.  What's that there
> > for?
> 
> Do you mean to ask why it's being modified at all here in this patch?
> It's referenced in the changelog a bit.  I believe it came from Mel at
> some point.  I didn't do much to that portion, but I happily drug those
> hunks along with my forward port.  I believe it's virtually all the same
> as what you posted here:
> 
> 	https://bugzilla.kernel.org/show_bug.cgi?id=50181

I'm now deeply confused.

Two days ago I merged a version which you sent me.  It is presently at
http://ozlabs.org/~akpm/mmotm/broken-out/debugging-keep-track-of-page-owners.patch.

Today you sent a new version.  My earlier email showed the difference
between these two versions.

AFACIT that difference was undescribed.  I can see that the new version
uses the stack-tracing infrastructure, but the change to
pagetypeinfo_showmixedcount_print() is a mystery.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
