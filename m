Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A8F986B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 16:09:46 -0400 (EDT)
Message-ID: <4A9C2E01.7080707@redhat.com>
Date: Mon, 31 Aug 2009 16:09:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <4A7AAE07.1010202@redhat.com> <20090806102057.GQ23385@random.random> <20090806105932.GA1569@localhost> <4A7AC201.4010202@redhat.com> <20090806130631.GB6162@localhost> <4A7AD79E.4020604@redhat.com> <20090816032822.GB6888@localhost> <4A878377.70502@redhat.com> <20090816045522.GA13740@localhost> <9EECC02A4CC333418C00A85D21E89326B6611F25@azsmsx502.amr.corp.intel.com> <20090821182439.GN29572@balbir.in.ibm.com> <9EECC02A4CC333418C00A85D21E8932601841832F9@azsmsx502.amr.corp.intel.com> <4A9C2A17.3080802@redhat.com> <9EECC02A4CC333418C00A85D21E893260184183339@azsmsx502.amr.corp.intel.com>
In-Reply-To: <9EECC02A4CC333418C00A85D21E893260184183339@azsmsx502.amr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dike, Jeffrey G wrote:
>> This will be because the VM does not start aging pages
>> from the active to the inactive list unless there is
>> some memory pressure.
> 
> Which is the reason I gave the VM a puny amount of memory. 
 > We know the thing is under memory pressure because I've been
 > complaining about page discards.

Page discards by the host, which are invisible to the guest
OS.

The guest OS thinks it has enough pages.  The host disagrees
and swaps out some guest memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
