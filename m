Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 036AF6B0087
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 16:57:57 -0400 (EDT)
Message-ID: <4AA17F36.4020702@redhat.com>
Date: Fri, 04 Sep 2009 16:57:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <4A846581.2020304@redhat.com> <20090813211626.GA28274@cmpxchg.org> <4A850F4A.9020507@redhat.com> <20090814091055.GA29338@cmpxchg.org> <20090814095106.GA3345@localhost> <4A856467.6050102@redhat.com> <20090815054524.GB11387@localhost> <9EECC02A4CC333418C00A85D21E89326B6611E81@azsmsx502.amr.corp.intel.com> <20090818022609.GA7958@localhost> <9EECC02A4CC333418C00A85D21E893260184184010@azsmsx502.amr.corp.intel.com> <20090903020452.GA9474@localhost> <9EECC02A4CC333418C00A85D21E8932601841D4A66@azsmsx502.amr.corp.intel.com>
In-Reply-To: <9EECC02A4CC333418C00A85D21E8932601841D4A66@azsmsx502.amr.corp.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dike, Jeffrey G wrote:
> Stupid question - what in your patch allows a text page get kicked out to the inactive list after you've given it an extra pass through the active list?

If it did not get referenced during its second pass through
the active list, it will get deactivated.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
