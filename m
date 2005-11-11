Date: Thu, 10 Nov 2005 16:51:37 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] dequeue a huge page near to this node
Message-ID: <20051111005137.GR29402@holomorphy.com>
References: <200511102334.jAANY1g21612@unix-os.sc.intel.com> <Pine.LNX.4.62.0511101643120.17138@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0511101643120.17138@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 10, 2005 at 04:44:40PM -0800, Christoph Lameter wrote:
> Well in that case, we may do even more:
> Make huge pages obey cpusets.
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Simple enough.

Acked-by: William Irwin <wli@holomorphy.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
