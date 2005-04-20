Date: Tue, 19 Apr 2005 18:38:52 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 0/4] io_remap_pfn_range: intro.
Message-ID: <20050420013852.GC2104@holomorphy.com>
References: <20050318112545.6f5f7635.rddunlap@osdl.org> <20050318125617.5e57c3f8.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050318125617.5e57c3f8.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org, riel@redhat.com, kurt@garloff.de, Keir.Fraser@cl.cam.ac.uk, Ian.Pratt@cl.cam.ac.uk, Christian.Limpach@cl.cam.ac.uk
List-ID: <linux-mm.kvack.org>

On Fri, 18 Mar 2005 11:25:45 -0800 "Randy.Dunlap" <rddunlap@osdl.org> wrote:
>> The sparc32 & sparc64 code needs live testing.

On Fri, Mar 18, 2005 at 12:56:17PM -0800, David S. Miller wrote:
> These patches look great Randy.  I think they should go in.
> If sparc explodes, I'll clean up the mess.  Any problem which
> crops up should not be difficult to solve.

Thanks for covering for me. My understanding of this area of the code
is very limited, so your help is much appreciated here.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
