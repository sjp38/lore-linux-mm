Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 20DA5600815
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 14:29:54 -0400 (EDT)
Date: Tue, 27 Jul 2010 12:29:49 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [RFC][PATCH 1/7][memcg] virtually indexed array library.
Message-ID: <20100727122949.3bfbfd0a@bike.lwn.net>
In-Reply-To: <20100727165303.7d7d18e9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165303.7d7d18e9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010 16:53:03 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> This virt-array allocates a virtally contiguous array via get_vm_area()
> and allows object allocation per an element of array.

Quick question: this looks a lot like the "flexible array" mechanism
which went in around a year ago, and which is documented in
Documentation/flexible-arrays.txt.  I'm not sure we need two of
these...  That said, it appears that there are still no users of
flexible arrays.  If your virtually-indexed arrays provide something
that flexible arrays don't, perhaps your implementation should replace
flexible arrays?

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
