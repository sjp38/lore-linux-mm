Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C066D6B0083
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 11:11:42 -0400 (EDT)
Date: Wed, 5 Aug 2009 17:11:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/12] ksm: pages_unshared and pages_volatile
Message-ID: <20090805151139.GY23385@random.random>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031311061.16754@sister.anvils>
 <20090804144920.bfc6a44f.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0908051216020.13195@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908051216020.13195@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, ieidus@redhat.com, riel@redhat.com, chrisw@redhat.com, nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 12:39:06PM +0100, Hugh Dickins wrote:
> procfs is not a nice interface for sysfs to be reading
> when it's asked to show pages_volatile!

Agreed, that is the real reason, grabbing that info from
slub/slab/slob (not so much from procfs) would be tricky.

Acked-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
