Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC966B0095
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 05:15:17 -0400 (EDT)
Date: Fri, 3 Sep 2010 11:15:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] Make is_mem_section_removable more conformable
 with offlining code
Message-ID: <20100903091509.GE10686@tiehlicka.suse.cz>
References: <20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
 <20100902092454.GA17971@tiehlicka.suse.cz>
 <AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
 <20100902131855.GC10265@tiehlicka.suse.cz>
 <AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
 <20100902143939.GD10265@tiehlicka.suse.cz>
 <20100902150554.GE10265@tiehlicka.suse.cz>
 <20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903121452.2d22b3aa.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903082558.GC10686@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903082558.GC10686@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Just in case that my old (buggy) approach still matters, here is the
updated (and hopefully fixed) patch.

---
