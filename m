Date: Tue, 19 Apr 2005 18:37:08 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 0/4] io_remap_pfn_range: intro.
Message-ID: <20050420013708.GB2104@holomorphy.com>
References: <20050318112545.6f5f7635.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050318112545.6f5f7635.rddunlap@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm <akpm@osdl.org>, davem@davemloft.net, riel@redhat.com, kurt@garloff.de, Keir.Fraser@cl.cam.ac.uk, Ian.Pratt@cl.cam.ac.uk, Christian.Limpach@cl.cam.ac.uk
List-ID: <linux-mm.kvack.org>

On Fri, Mar 18, 2005 at 11:25:45AM -0800, Randy.Dunlap wrote:
> This is a combination of io_remap_pfn_range patches posted in the
> last week or so by Keir Fraser and me.
> This description is mostly from Keir's original post.
> This patch introduces a new interface function for mapping bus/device
> memory: io_remap_pfn_range. This accepts the same parameters as
> remap_pfn_range and io_remap_page_range but should be used in any
> situation where the caller is not simply remapping ordinary RAM.
> For example, when mapping device registers the new function should be used.
> The distinction between remapping device memory and ordinary RAM is
> critical for the Xen hypervisor.
> This patch series also cleans up the remaining users of
> io_remap_page_range (in particular, the several sparc-specific
> sections in various drivers that use a special form of io_remap_page_range:
> an extra <iospace> argument for SPARC arch.) by converting them to
> use io_remap_pfn_range(), where io_remap_pfn_range() supports
> passing <iospace> as part of the pfn argument.
> The sparc32 & sparc64 code needs live testing.

Thanks for covering this for me (not that I've contributed a line of
code to this). I've got a very limited range of devices to test on
sparc so I'll have to wait for users' reports to come in.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
