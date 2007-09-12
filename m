Date: Wed, 12 Sep 2007 15:38:11 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 15 of 24] limit reclaim if enough pages have been freed
Message-ID: <20070912133811.GK21600@v2.random>
References: <patchbomb.1187786927@v2.random> <94686cfcd27347e83a6a.1187786942@v2.random> <20070912055800.ed2c45ce.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912055800.ed2c45ce.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 05:58:00AM -0700, Andrew Morton wrote:
> Also, this has nothing to do with oom-killing, which is the subject of this
> patch series?

Yes, but at least I kept this in a separated patch ;). Most of the VM
changes were strictly OOM related that's the reason of the subject.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
