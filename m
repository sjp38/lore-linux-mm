Received: from m7.gw.fujitsu.co.jp ([10.0.50.77]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7R64XwH020173 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 15:04:33 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7R64WsA028743 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 15:04:32 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106]) by s4.gw.fujitsu.co.jp (8.12.11)
	id i7R64VBF020842 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 15:04:31 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3300MK2CVI9Y@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri, 27 Aug 2004 15:04:31 +0900 (JST)
Date: Fri, 27 Aug 2004 15:09:41 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
In-reply-to: <1093585627.2984.485.camel@nighthawk>
Message-id: <412ED025.7070907@jp.fujitsu.com>
MIME-version: 1.0
Content-type: multipart/mixed; boundary="------------010902090300090803010100"
References: <412DD1AA.8080408@jp.fujitsu.com>
 <1093535402.2984.11.camel@nighthawk> <412E6CC3.8060908@jp.fujitsu.com>
 <20040826171840.4a61e80d.akpm@osdl.org> <412E8009.3080508@jp.fujitsu.com>
 <412EBD22.2090508@jp.fujitsu.com> <1093585627.2984.485.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010902090300090803010100
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

It's is against pure 2.6.8.1-mm4 tree.

I'm afraid that there was cut & paste mistake of mine,
so I send it in tgz file again.

patch order)
1.  eliminate-bitmap-includes.patch
2.  eliminate-bitmap-init.patch
3.  eliminate-bitmap-alloc.patch
4.  eliminate-bitmap-free.patch
5.  eliminate-bitmap-prefetch.patch


-- Kame

Dave Hansen wrote:

> I can't seem to get patch 2 to apply.  Were they again a plain
> 2.6.8.1-mm4 tree, or were some other patches involved too?  They were
> supposed to go in numerical order, right?
> 
> -- Dave
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--------------010902090300090803010100
Content-Type: application/x-compressed;
 name="eliminate-bitmap.tgz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="eliminate-bitmap.tgz"

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
--------------010902090300090803010100--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
