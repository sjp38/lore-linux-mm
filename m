Date: Fri, 18 Mar 2005 12:56:17 -0800
From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/4] io_remap_pfn_range: intro.
Message-Id: <20050318125617.5e57c3f8.davem@davemloft.net>
In-Reply-To: <20050318112545.6f5f7635.rddunlap@osdl.org>
References: <20050318112545.6f5f7635.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org, wli@holomorphy.com, riel@redhat.com, kurt@garloff.de, Keir.Fraser@cl.cam.ac.uk, Ian.Pratt@cl.cam.ac.uk, Christian.Limpach@cl.cam.ac.uk
List-ID: <linux-mm.kvack.org>

On Fri, 18 Mar 2005 11:25:45 -0800
"Randy.Dunlap" <rddunlap@osdl.org> wrote:

> The sparc32 & sparc64 code needs live testing.

These patches look great Randy.  I think they should go in.

If sparc explodes, I'll clean up the mess.  Any problem which
crops up should not be difficult to solve.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
