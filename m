Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4AF336B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 14:07:07 -0400 (EDT)
Date: Fri, 21 May 2010 13:03:51 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: RE: [PATCH] slub: move kmem_cache_node into it's own cacheline
In-Reply-To: <6E3BC7F7C9A4BF4286DD4C043110F30B0B5969081B@shsmsx502.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1005211301510.14851@router.home>
References: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com> <AANLkTilfJh65QAkb9FPaqI3UEtbgwLuuoqSdaTtIsXWZ@mail.gmail.com> <6E3BC7F7C9A4BF4286DD4C043110F30B0B5969081B@shsmsx502.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Shi, Alex" <alex.shi@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>


Yes right. The cacheline that also contains local_node is dirtied by the
locking in the SMP case and will evict the cacheline used to lookup the
per cpu vector and other important information. The per cpu patches
aggravated that problem by making more use of the fields that are evicted
with the cacheline.

Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
