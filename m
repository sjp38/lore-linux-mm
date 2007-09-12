Date: Wed, 12 Sep 2007 15:36:02 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 19 of 24] cacheline align VM_is_OOM to prevent false
	sharing
Message-ID: <20070912133602.GJ21600@v2.random>
References: <patchbomb.1187786927@v2.random> <be2fc447cec06990a2a3.1187786946@v2.random> <20070912060255.c5b95414.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912060255.c5b95414.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 06:02:55AM -0700, Andrew Morton wrote:
> I'd suggest __read_mostly.

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
