Date: Wed, 19 Sep 2007 11:00:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 13/26] SLUB: Add SlabReclaimable() to avoid repeated reclaim
 attempts
In-Reply-To: <46F13B6C.7020501@redhat.com>
Message-ID: <Pine.LNX.4.64.0709191100260.11882@schroedinger.engr.sgi.com>
References: <20070901014107.719506437@sgi.com> <20070901014222.303468369@sgi.com>
 <46F13B6C.7020501@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, Rik van Riel wrote:

> Why is it safe to not use the normal page flag bit operators
> for these page flags operations?

Because SLUB always modifies page flags under PageLock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
