Date: Thu, 3 Jan 2008 01:55:49 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 04 of 24] serialize oom killer
Message-ID: <20080103005549.GH30939@v2.random>
References: <patchbomb.1187786927@v2.random> <871b7a4fd566de081120.1187786931@v2.random> <20070912050205.a6b243a2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912050205.a6b243a2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 05:02:05AM -0700, Andrew Morton wrote:
> Please use mutexes, not semaphores.  I'll make this change.
> 
> I think this patch needs more explanation/justification.

It's probably obsolete to discuss this as the zone-oom-lock mostly
obsoletes this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
