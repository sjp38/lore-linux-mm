Date: Tue, 31 Aug 2004 16:24:08 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Lhms-devel] Re: [RFC] buddy allocator without bitmap(2) [0/3]
Message-Id: <20040831162408.3718c83e.akpm@osdl.org>
In-Reply-To: <4134FF50.8000300@jp.fujitsu.com>
References: <41345491.1020209@jp.fujitsu.com>
	<1093969590.26660.4806.camel@nighthawk>
	<4134FF50.8000300@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Because I had to record some information about shape of mem_map, I used PG_xxx bit.
> 1 bit is maybe minimum consumption.

The point is that we're running out of bits in page.flags.

You should be able to reuse an existing bit for this application.  PG_lock would suit.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
