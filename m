Subject: Re: [-mm PATCH 6/8] Memory controller add per container LRU and
 reclaim
	(v2)
In-Reply-To: Your message of "Thu, 05 Jul 2007 22:22:12 -0700"
	<20070706052212.11677.26502.sendpatchset@balbir-laptop>
References: <20070706052212.11677.26502.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20070710084153.C07D91BF6B5@siro.lan>
Date: Tue, 10 Jul 2007 17:41:53 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: svaidy@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@openvz.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com
List-ID: <linux-mm.kvack.org>

> Add the meta_page to the per container LRU. The reclaim algorithm has been
> modified to make the isolate_lru_pages() as a pluggable component. The
> scan_control data structure now accepts the container on behalf of which
> reclaims are carried out. try_to_free_pages() has been extended to become
> container aware.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

it seems that the number of pages to scan (nr_active/nr_inactive
in shrink_zone) is calculated from NR_ACTIVE and NR_INACTIVE of the zone,
even in the case of per-container reclaim.  is it intended?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
