Date: Mon, 18 Sep 2006 13:28:18 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Get rid of zone_table V2
Message-Id: <20060918132818.603196e2.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Sep 2006 12:21:35 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> The zone table is mostly not needed. If we have a node in the
> page flags then we can get to the zone via NODE_DATA() which
> is much more likely to be already in the cpu cache.

Adds a couple of hundred bytes of text to an x86 SMP build.  Any
idea why?  If it's things like page_zone() getting porkier then that's
a bit unfortunate - that's rather fastpath material.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
