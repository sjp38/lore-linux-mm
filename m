Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 296086B006A
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 16:06:30 -0400 (EDT)
From: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Date: Fri, 4 Sep 2009 13:06:28 -0700
Subject: RE: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <9EECC02A4CC333418C00A85D21E8932601841D4A66@azsmsx502.amr.corp.intel.com>
References: <4A846581.2020304@redhat.com>
 <20090813211626.GA28274@cmpxchg.org> <4A850F4A.9020507@redhat.com>
 <20090814091055.GA29338@cmpxchg.org> <20090814095106.GA3345@localhost>
 <4A856467.6050102@redhat.com> <20090815054524.GB11387@localhost>
 <9EECC02A4CC333418C00A85D21E89326B6611E81@azsmsx502.amr.corp.intel.com>
 <20090818022609.GA7958@localhost>
 <9EECC02A4CC333418C00A85D21E893260184184010@azsmsx502.amr.corp.intel.com>
 <20090903020452.GA9474@localhost>
In-Reply-To: <20090903020452.GA9474@localhost>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Stupid question - what in your patch allows a text page get kicked out to t=
he inactive list after you've given it an extra pass through the active lis=
t?

					Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
