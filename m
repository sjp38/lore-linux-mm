Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 667878D003F
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 02:03:57 -0500 (EST)
Received: by fxm12 with SMTP id 12so275777fxm.14
        for <linux-mm@kvack.org>; Wed, 19 Jan 2011 23:03:55 -0800 (PST)
Message-ID: <4D37DE56.7020909@monstr.eu>
Date: Thu, 20 Jan 2011 08:03:50 +0100
From: Michal Simek <monstr@monstr.eu>
Reply-To: monstr@monstr.eu
MIME-Version: 1.0
Subject: Re: [PATCH 13 of 66] export maybe_mkwrite
References: <patchbomb.1288798055@v2.random> <15324c9c30081da3a740.1288798068@v2.random> <4D344EAF.1080401@petalogix.com> <20110117143345.GQ9506@random.random> <4D35A3D6.4070801@monstr.eu> <20110118203237.GF9506@random.random>
In-Reply-To: <20110118203237.GF9506@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Simek <monstr@monstr.eu>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Tue, Jan 18, 2011 at 03:29:42PM +0100, Michal Simek wrote:
>> Of course: Look for example at this page:
>> http://www.monstr.eu/wiki/doku.php?id=log:2011-01-18_11_51_49#linux_next
> 
> Ok now I see, the problem is the lack of pte_mkwrite with MMU=n.
> 
> So either we apply your patch or we move the maybe_mkwrite at the top
> of huge_mm.h (before #ifdef CONFIG_TRANSPARENT_HUGEPAGE), it's up to
> you...

If you mean me, IRC there are some !MMU that's why I prefer to use my 
origin version.

Who kill take care about this fix? I prefer to add it to mainline ASAP 
to fix all noMMU platforms.

Thanks,
Michal


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
