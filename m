Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 193AC6B00A4
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 07:42:18 -0400 (EDT)
Date: Fri, 3 Sep 2010 13:42:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] Make is_mem_section_removable more conformable
 with offlining code v3
Message-ID: <20100903114213.GI10686@tiehlicka.suse.cz>
References: <20100902131855.GC10265@tiehlicka.suse.cz>
 <AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
 <20100902143939.GD10265@tiehlicka.suse.cz>
 <20100902150554.GE10265@tiehlicka.suse.cz>
 <20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903121452.2d22b3aa.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903082558.GC10686@tiehlicka.suse.cz>
 <20100903181327.7dad3f84.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903095049.GG10686@tiehlicka.suse.cz>
 <20100903190520.8751aab6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903190520.8751aab6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Here is the updated version of my original patch based on the
KAMEZAWA Hiroyuki feedback.

What do other people think about that?

On Fri 03-09-10 19:05:20, KAMEZAWA Hiroyuki wrote:
[...]
> ok, let's go step by step.
> 
> I'm ok that your new patch to be merged. I'll post some clean up and small
> bugfix (not related to your patch), later.
> (I'll be very busy in this weekend, sorry.)

---
