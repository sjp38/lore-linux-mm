Subject: Re: A scrub daemon (prezeroing)
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 27 Jan 2005 12:15:24 +0000
Message-Id: <1106828124.19262.45.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2005-01-21 at 12:29 -0800, Christoph Lameter wrote:
> Adds management of ZEROED and NOT_ZEROED pages and a background daemon
> called scrubd. scrubd is disabled by default but can be enabled
> by writing an order number to /proc/sys/vm/scrub_start. If a page
> is coalesced of that order or higher then the scrub daemon will
> start zeroing until all pages of order /proc/sys/vm/scrub_stop and
> higher are zeroed and then go back to sleep.

Some architectures tend to have spare DMA engines lying around. There's
no need to use the CPU for zeroing pages. How feasible would it be for
scrubd to use these?

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
