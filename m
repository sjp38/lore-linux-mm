Date: Fri, 21 Mar 2008 10:35:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [2/2] vmallocinfo: Add caller information
In-Reply-To: <20080321110008.GW20420@elte.hu>
Message-ID: <Pine.LNX.4.64.0803211034140.18671@schroedinger.engr.sgi.com>
References: <20080318222701.788442216@sgi.com> <20080318222827.519656153@sgi.com>
 <20080319214227.GA4454@elte.hu> <Pine.LNX.4.64.0803191659410.4645@schroedinger.engr.sgi.com>
 <20080321110008.GW20420@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Mar 2008, Ingo Molnar wrote:

> then make STACKTRACE available generally via the patch below.

How do I figure out which nesting level to display if we'd do this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
