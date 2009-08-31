Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F365E6B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 16:06:45 -0400 (EDT)
From: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Date: Mon, 31 Aug 2009 13:06:09 -0700
Subject: RE: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <9EECC02A4CC333418C00A85D21E893260184183339@azsmsx502.amr.corp.intel.com>
References: <4A7AAE07.1010202@redhat.com>
 <20090806102057.GQ23385@random.random> <20090806105932.GA1569@localhost>
 <4A7AC201.4010202@redhat.com> <20090806130631.GB6162@localhost>
 <4A7AD79E.4020604@redhat.com> <20090816032822.GB6888@localhost>
 <4A878377.70502@redhat.com> <20090816045522.GA13740@localhost>
 <9EECC02A4CC333418C00A85D21E89326B6611F25@azsmsx502.amr.corp.intel.com>
 <20090821182439.GN29572@balbir.in.ibm.com>
 <9EECC02A4CC333418C00A85D21E8932601841832F9@azsmsx502.amr.corp.intel.com>
 <4A9C2A17.3080802@redhat.com>
In-Reply-To: <4A9C2A17.3080802@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> This will be because the VM does not start aging pages
> from the active to the inactive list unless there is
> some memory pressure.

Which is the reason I gave the VM a puny amount of memory.  We know the thi=
ng is under memory pressure because I've been complaining about page discar=
ds.  I didn't collect that data on this run, but I'll do it again to make s=
ure.

					Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
