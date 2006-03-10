Date: Fri, 10 Mar 2006 11:12:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/03] Unmapped: Separate unmapped and mapped pages
In-Reply-To: <20060310034412.8340.90939.sendpatchset@cherry.local>
Message-ID: <Pine.LNX.4.64.0603101111570.28805@schroedinger.engr.sgi.com>
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Mar 2006, Magnus Damm wrote:

> Unmapped patches - Use two LRU:s per zone.

Note that if this is done then the default case of zone_reclaim becomes 
trivial to deal with and we can get rid of the zone_reclaim_interval.

However, I have not looked at the rest yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
