Date: Tue, 12 Oct 2004 08:38:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA: Patch for node based swapping
In-Reply-To: <1513170000.1097594210@[10.10.2.4]>
Message-ID: <Pine.LNX.4.58.0410120838100.12195@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0410120751010.11558@schroedinger.engr.sgi.com>
 <1513170000.1097594210@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Oct 2004, Martin J. Bligh wrote:

> PS, might be possible to add a mechanism to ask kswapd to reclaim some
> cache pages without doing swapout, but I fear of messing with the delicate
> balance of the universe - cache vs user.

That is also my concern. I think the patch is useful to address the
immediate issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
