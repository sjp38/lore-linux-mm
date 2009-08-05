Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5B2C66B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:00:18 -0400 (EDT)
From: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Date: Wed, 5 Aug 2009 12:00:13 -0700
Subject: RE: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <9EECC02A4CC333418C00A85D21E89326B651C1FE@azsmsx502.amr.corp.intel.com>
References: <20090805024058.GA8886@localhost> <4A79C70C.6010200@redhat.com>
In-Reply-To: <4A79C70C.6010200@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>, "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Also, the inactive list (where references to anonymous pages
> _do_ count) is pretty big.  Is it not big enough in Jeff's
> test case?

> Jeff, what kind of workloads are you running in the guests?

I'm looking at KVM on small systems.  My "small system" is a 128M memory co=
mpartment on a 4G server.

The workload is boot up the instance, start Firefox and another app (whatev=
er editor comes by default with Moblin), close them, and shut down the inst=
ance.

					Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
