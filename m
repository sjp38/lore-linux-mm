Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6BB216B005D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 11:45:09 -0400 (EDT)
From: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Date: Wed, 5 Aug 2009 08:45:04 -0700
Subject: RE: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <9EECC02A4CC333418C00A85D21E89326B651C07C@azsmsx502.amr.corp.intel.com>
References: <20090805024058.GA8886@localhost> <4A793B92.9040204@redhat.com>
In-Reply-To: <4A793B92.9040204@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>, "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Jeff, do you see the refaults on Nehalem systems?

My test box is pre-Nehalem - no EPT.

					Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
