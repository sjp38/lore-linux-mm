Date: Thu, 26 Aug 2004 17:18:40 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
Message-Id: <20040826171840.4a61e80d.akpm@osdl.org>
In-Reply-To: <412E6CC3.8060908@jp.fujitsu.com>
References: <412DD1AA.8080408@jp.fujitsu.com>
	<1093535402.2984.11.camel@nighthawk>
	<412E6CC3.8060908@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> In the previous version, I used SetPagePrivate()/ClearPagePrivate()/PagePrivate().
> But these are "atomic" operation and looks very slow.
> This is why I doesn't used these macros in this version.
> 
> My previous version, which used set_bit/test_bit/clear_bit, shows very bad performance
> on my test, and I replaced it.

That's surprising.  But if you do intend to use non-atomic bitops then
please add __SetPagePrivate() and __ClearPagePrivate()
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
