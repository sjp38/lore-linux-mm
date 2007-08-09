Date: Thu, 9 Aug 2007 14:19:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/4] Use one zonelist per node instead of multiple
 zonelists v3
In-Reply-To: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708091418470.32324@schroedinger.engr.sgi.com>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Aug 2007, Mel Gorman wrote:

> o Encode zone_id in the zonelist pointers to avoid zone_idx() (Christoph's idea)

That is addressed by this patch it seems?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
