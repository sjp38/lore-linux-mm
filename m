Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6F3C66B004F
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 14:06:13 -0400 (EDT)
From: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Date: Mon, 17 Aug 2009 11:04:46 -0700
Subject: RE: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <9EECC02A4CC333418C00A85D21E89326B6611E81@azsmsx502.amr.corp.intel.com>
References: <20090813010356.GA7619@localhost> <4A843565.3010104@redhat.com>
 <4A843B72.6030204@redhat.com> <4A843EAE.6070200@redhat.com>
 <4A846581.2020304@redhat.com> <20090813211626.GA28274@cmpxchg.org>
 <4A850F4A.9020507@redhat.com> <20090814091055.GA29338@cmpxchg.org>
 <20090814095106.GA3345@localhost> <4A856467.6050102@redhat.com>
 <20090815054524.GB11387@localhost>
In-Reply-To: <20090815054524.GB11387@localhost>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Jeff, can you confirm if the mem cgroup's inactive list is small?

Nope.  I have plenty on the inactive anon list, between 13K and 16K pages (=
i.e. 52M to 64M).

The inactive mapped list is much smaller - 0 to ~700 pages.

The active lists are comparable in size, but larger - 16K - 19K pages for a=
non and 60 - 450 pages for mapped.

						Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
