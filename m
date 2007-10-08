Date: Mon, 8 Oct 2007 13:39:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: BUG: soft lockup in flush_tlb_page()
In-Reply-To: <391574848.27001@ustc.edu.cn>
Message-ID: <Pine.LNX.4.64.0710081336170.30446@schroedinger.engr.sgi.com>
References: <391574848.27001@ustc.edu.cn>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Oct 2007, Fengguang Wu wrote:

> A soft lockup was detected when doing 'make -j4'. 
> It occurred only once in 2.6.23-rc8-mm2 till now.

We have had these sporadically on IA64. Long latencies may cause the soft 
lockup detection to misfire on large cpu configurations. You got a lot of 
debugging enabled?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
