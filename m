Date: Tue, 11 Nov 2008 18:28:57 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 0/7] cpu alloc stage 2
In-Reply-To: <20081111155611.93b978df.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0811111827370.31625@quilx.com>
References: <20081105231634.133252042@quilx.com> <20081111155611.93b978df.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, sfr@canb.auug.org.au, vegard.nossum@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2008, Andrew Morton wrote:

> It all looks very nice to me.  It's a shame about the lack of any
> commonality with local_t though.

At the end of the full patchset local_t is no more because cpu ops can
completely replace all use cases for local_t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
