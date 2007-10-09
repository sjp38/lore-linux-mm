Message-ID: <391892342.28144@ustc.edu.cn>
Date: Tue, 9 Oct 2007 09:12:18 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: BUG: soft lockup in flush_tlb_page()
Message-ID: <20071009011218.GA6759@mail.ustc.edu.cn>
References: <391574848.27001@ustc.edu.cn> <Pine.LNX.4.64.0710081336170.30446@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710081336170.30446@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 08, 2007 at 01:39:19PM -0700, Christoph Lameter wrote:
> On Fri, 5 Oct 2007, Fengguang Wu wrote:
> 
> > A soft lockup was detected when doing 'make -j4'. 
> > It occurred only once in 2.6.23-rc8-mm2 till now.
> 
> We have had these sporadically on IA64. Long latencies may cause the soft 
> lockup detection to misfire on large cpu configurations. You got a lot of 
> debugging enabled?

Yes ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
