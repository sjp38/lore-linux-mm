Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 2E43E6B0092
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 17:37:39 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 7 Dec 2012 15:37:38 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6456419D8042
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 15:37:35 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB7MbY3u291804
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 15:37:34 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB7MbYG9010057
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 15:37:34 -0700
Message-ID: <50C26FA7.9010000@linux.vnet.ibm.com>
Date: Fri, 07 Dec 2012 14:37:27 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Debugging: Keep track of page owners
References: <20121207212417.FAD8DAED@kernel.stglabs.ibm.com> <20121207142614.428b8a54.akpm@linux-foundation.org>
In-Reply-To: <20121207142614.428b8a54.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On 12/07/2012 02:26 PM, Andrew Morton wrote:\
> I have cunningly divined the intention of your update and have queued
> the below incremental.  The change to
> pagetypeinfo_showmixedcount_print() was a surprise.  What's that there
> for?

Do you mean to ask why it's being modified at all here in this patch?
It's referenced in the changelog a bit.  I believe it came from Mel at
some point.  I didn't do much to that portion, but I happily drug those
hunks along with my forward port.  I believe it's virtually all the same
as what you posted here:

	https://bugzilla.kernel.org/show_bug.cgi?id=50181


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
