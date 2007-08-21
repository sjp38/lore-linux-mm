Date: Tue, 21 Aug 2007 13:48:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
In-Reply-To: <1187692586.6114.211.camel@twins>
Message-ID: <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <1187692586.6114.211.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Aug 2007, Peter Zijlstra wrote:

> This almost insta-OOMs with anonymous workloads.

What does the workload do? So writeout needs to begin earlier. There are 
likely issues with throttling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
