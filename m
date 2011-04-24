Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BE7108D003B
	for <linux-mm@kvack.org>; Sun, 24 Apr 2011 12:27:22 -0400 (EDT)
Date: Sun, 24 Apr 2011 12:27:14 -0400
From: John David Anglin <dave@hiauly1.hia.nrc.ca>
Subject: Re: [PATCH] convert parisc to sparsemem (was Re: [PATCH v3] mm:
	make expand_downwards symmetrical to expand_upwards)
Message-ID: <20110424162713.GA1954@hiauly1.hia.nrc.ca>
Reply-To: John David Anglin <dave.anglin@nrc-cnrc.gc.ca>
References: <1303337718.2587.51.camel@mulgrave.site> <alpine.DEB.2.00.1104201530430.13948@chino.kir.corp.google.com> <20110421221712.9184.A69D9226@jp.fujitsu.com> <1303403847.4025.11.camel@mulgrave.site> <alpine.DEB.2.00.1104211328000.5741@router.home> <1303411537.9048.3583.camel@nimitz> <1303507985.2590.47.camel@mulgrave.site> <1303583657.4116.11.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1303583657.4116.11.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>

On Sat, 23 Apr 2011, James Bottomley wrote:

> The boot sequence got a few seconds slower because now all of the loops
> over our pfn ranges actually have to skip through the holes (which takes
> time for 64GB).

On my rp3440, the biggest gap seems to be 265GB:

dave@mx3210:~$ cat /proc/iomem
00000000-3fffffff : System RAM
00000000-000009ff : PDC data (Page Zero)
00100000-004acfff : Kernel code
004ad000-00661fff : Kernel data
40000000-4fffffff : IOVA Space
100000000-27fdfffff : System RAM
4040000000-40ffffffff : System RAM

Dave
-- 
J. David Anglin                                  dave.anglin@nrc-cnrc.gc.ca
National Research Council of Canada              (613) 990-0752 (FAX: 952-6602)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
