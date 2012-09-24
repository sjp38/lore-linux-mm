Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id B6D886B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 05:14:35 -0400 (EDT)
Message-ID: <1348478089.10257.3.camel@jlt4.sipsolutions.net>
Subject: Re: iwl3945: order 5 allocation during ifconfig up; vm problem?
From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 24 Sep 2012 11:14:49 +0200
In-Reply-To: <20120924090353.GA5368@mwanda>
References: <20120909213228.GA5538@elf.ucw.cz>
	 <alpine.DEB.2.00.1209091539530.16930@chino.kir.corp.google.com>
	 <20120910111113.GA25159@elf.ucw.cz>
	 <20120911162536.bd5171a1.akpm@linux-foundation.org>
	 <1347426988.13103.684.camel@edumazet-glaptop>
	 <20120912055712.GE11613@merlins.org>
	 <1347432846.4293.0.camel@jlt4.sipsolutions.net>
	 <20120924090353.GA5368@mwanda>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Marc MERLIN <marc@merlins.org>, Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Machek <pavel@ucw.cz>, David Rientjes <rientjes@google.com>, sgruszka@redhat.com, linux-wireless@vger.kernel.org, wey-yi.w.guy@intel.com, ilw@linux.intel.com, Andrew Morton <akpm@osdl.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-09-24 at 12:03 +0300, Dan Carpenter wrote:

> > > > iwl_alloc_ucode() -> iwl_alloc_fw_desc() -> dma_alloc_coherent()
> 
> I'm filing bugzilla entries for regressions.  What's the status on
> this?

It looks like a VM change caused it, but I merged a patch for -next to
not require such large DMA allocations any more.

johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
