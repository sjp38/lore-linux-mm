Date: Fri, 21 Mar 2008 22:09:41 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [1/2] vmalloc: Show vmalloced areas via /proc/vmallocinfo
Message-ID: <20080321220941.6b441801@core>
In-Reply-To: <20080321151935.6a330536.akpm@linux-foundation.org>
References: <20080318222701.788442216@sgi.com>
	<20080318222827.291587297@sgi.com>
	<20080319210436.191bb8fe@laptopd505.fenrus.org>
	<Pine.LNX.4.64.0803201141250.10592@schroedinger.engr.sgi.com>
	<20080321151935.6a330536.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, arjan@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> That makes the feature somewhat less useful.  Let's think this through more
> carefully - it is, after all, an unrevokable, unalterable addition to the
> kernel ABI.

Which means it does not belong in /proc.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
