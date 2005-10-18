Date: Tue, 18 Oct 2005 09:47:35 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 0/2] Page migration via Swap V2: Overview
In-Reply-To: <4354696D.4050101@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.62.0510180946220.7911@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
 <4354696D.4050101@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, ak@suse.de, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 18 Oct 2005, KAMEZAWA Hiroyuki wrote:

> I think migration cache will work well for A & B :)
> migraction cache is virtual swap, just unmap a page and modifies it as a swap
> cache.

That would be great. Cold you rework the migration cache patch to apply to 
2.6.14-rc4-mm1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
