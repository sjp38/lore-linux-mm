Date: Thu, 23 Aug 2007 00:15:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re:
 vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru
Message-Id: <20070823001517.1252911b.akpm@linux-foundation.org>
In-Reply-To: <20070823041137.GH18788@wotan.suse.de>
References: <20070823041137.GH18788@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Martin Bligh <mbligh@mbligh.org>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2007 06:11:37 +0200 Nick Piggin <npiggin@suse.de> wrote:

> http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc3/2.6.23-rc3-mm1/broken-out/vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
> 
> About this patch... I hope it doesn't get merged without good reason...

I have no intention at all of merging it until it's proven to be a net
benefit.  This is engineering.  We shouldn't merge VM changes based on
handwaving.

It does fix a bug (ie: a difference between design intent and
implementation) but I have no idea whether it improves or worsens anything.

> [handwaving]

;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
