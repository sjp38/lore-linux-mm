From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones pointer
Date: Fri, 10 Aug 2007 20:13:48 +0200
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie> <20070810104749.GA14300@skynet.ie> <Pine.LNX.4.64.0708101035020.12758@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708101035020.12758@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708102013.49170.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> x86_64 does not support ZONE_HIGHMEM.

I also plan to eliminate ZONE_DMA soon (and replace all its users
with a new allocator that sits outside the normal fallback lists) 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
