Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 83E836B004F
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 17:42:18 -0400 (EDT)
From: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Date: Fri, 14 Aug 2009 14:42:10 -0700
Subject: RE: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <9EECC02A4CC333418C00A85D21E89326B6611AC5@azsmsx502.amr.corp.intel.com>
References: <20090812074820.GA29631@localhost> <4A82D24D.6020402@redhat.com>
 <20090813010356.GA7619@localhost> <4A843565.3010104@redhat.com>
 <4A843B72.6030204@redhat.com> <4A843EAE.6070200@redhat.com>
 <4A846581.2020304@redhat.com> <20090813211626.GA28274@cmpxchg.org>
 <4A850F4A.9020507@redhat.com> <20090814091055.GA29338@cmpxchg.org>
 <20090814095106.GA3345@localhost>
In-Reply-To: <20090814095106.GA3345@localhost>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

A side note - I've been doing some tracing and shrink_active_list is called=
 a humongous number of times (25000-ish during a ~90 kvm run), with a net r=
esult of zero pages moved nearly all the time.  Your test is rescuing essen=
tially all candidate pages from the inactive list.  Right now, I have the V=
M_EXEC || PageAnon version of your test.

						Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
