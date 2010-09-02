Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1843A6B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 11:06:00 -0400 (EDT)
Date: Thu, 2 Sep 2010 17:05:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-ID: <20100902150554.GE10265@tiehlicka.suse.cz>
References: <20100901121951.GC6663@tiehlicka.suse.cz>
 <20100901124138.GD6663@tiehlicka.suse.cz>
 <20100902144500.a0d05b08.kamezawa.hiroyu@jp.fujitsu.com>
 <20100902082829.GA10265@tiehlicka.suse.cz>
 <20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
 <20100902092454.GA17971@tiehlicka.suse.cz>
 <AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
 <20100902131855.GC10265@tiehlicka.suse.cz>
 <AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
 <20100902143939.GD10265@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100902143939.GD10265@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

I am sorry for re-posting the patch again but I found out that my config
didn't have CONFIG_HOTREMOVE so the code wasn't compiled and I didn't
catch include problems (missing symbols etc.). The patch compiles now,
finally.

---
