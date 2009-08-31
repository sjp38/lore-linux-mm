Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A41736B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 16:42:42 -0400 (EDT)
Received: by pxi7 with SMTP id 7so320247pxi.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2009 13:42:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9EECC02A4CC333418C00A85D21E893260184183346@azsmsx502.amr.corp.intel.com>
References: <4A7AAE07.1010202@redhat.com> <4A878377.70502@redhat.com>
	 <20090816045522.GA13740@localhost>
	 <9EECC02A4CC333418C00A85D21E89326B6611F25@azsmsx502.amr.corp.intel.com>
	 <20090821182439.GN29572@balbir.in.ibm.com>
	 <9EECC02A4CC333418C00A85D21E8932601841832F9@azsmsx502.amr.corp.intel.com>
	 <4A9C2A17.3080802@redhat.com>
	 <9EECC02A4CC333418C00A85D21E893260184183339@azsmsx502.amr.corp.intel.com>
	 <4A9C2E01.7080707@redhat.com>
	 <9EECC02A4CC333418C00A85D21E893260184183346@azsmsx502.amr.corp.intel.com>
Date: Tue, 1 Sep 2009 02:12:44 +0530
Message-ID: <661de9470908311342gcdc3eb7v261951221212e549@mail.gmail.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Cc: Rik van Riel <riel@redhat.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 1, 2009 at 1:41 AM, Dike, Jeffrey G<jeffrey.g.dike@intel.com> w=
rote:
>> Page discards by the host, which are invisible to the guest
>> OS.
>
> Duh. =A0Right - I can't keep my VM systems straight...
>

Sounds like we need a way of indicating reference information. Guest
page hinting (cough; cough) anyone? May be a simpler version?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
