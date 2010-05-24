Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D2C096B01B1
	for <linux-mm@kvack.org>; Mon, 24 May 2010 14:14:26 -0400 (EDT)
Message-ID: <4BFAC1FC.2030502@cs.helsinki.fi>
Date: Mon, 24 May 2010 21:14:20 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: move kmem_cache_node into it's own cacheline
References: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com> <AANLkTilfJh65QAkb9FPaqI3UEtbgwLuuoqSdaTtIsXWZ@mail.gmail.com> <6E3BC7F7C9A4BF4286DD4C043110F30B0B5969081B@shsmsx502.ccr.corp.intel.com>
In-Reply-To: <6E3BC7F7C9A4BF4286DD4C043110F30B0B5969081B@shsmsx502.ccr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Shi, Alex" <alex.shi@intel.com>
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>, "cl@linux.com" <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
