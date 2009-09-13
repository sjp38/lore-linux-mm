Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 183FD6B004F
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 12:23:12 -0400 (EDT)
Received: by yxe12 with SMTP id 12so3457027yxe.1
        for <linux-mm@kvack.org>; Sun, 13 Sep 2009 09:23:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9EECC02A4CC333418C00A85D21E89326B6611AC5@azsmsx502.amr.corp.intel.com>
References: <20090812074820.GA29631@localhost> <4A843565.3010104@redhat.com>
	 <4A843B72.6030204@redhat.com> <4A843EAE.6070200@redhat.com>
	 <4A846581.2020304@redhat.com> <20090813211626.GA28274@cmpxchg.org>
	 <4A850F4A.9020507@redhat.com> <20090814091055.GA29338@cmpxchg.org>
	 <20090814095106.GA3345@localhost>
	 <9EECC02A4CC333418C00A85D21E89326B6611AC5@azsmsx502.amr.corp.intel.com>
Date: Mon, 14 Sep 2009 01:23:19 +0900
Message-ID: <2f11576a0909130923i3795a91bxd0cc0fe7b19a1e3b@mail.gmail.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Jeff,

> A side note - I've been doing some tracing and shrink_active_list is call=
ed a humongous number of times (25000-ish during a ~90 kvm run), with a net=
 result of zero pages moved nearly all the time. =A0Your test is rescuing e=
ssentially all candidate pages from the inactive list. =A0Right now, I have=
 the VM_EXEC || PageAnon version of your test.

Sorry for the long delayed replay.
I made reproduce environment today. but I don't have luck. I didn't
reproduce stack refault issue.
Could you please explain detailed reproduce way and your analysis way?

My environment is,
  x86_64 CPUx4 MEM 6G
  userland: fedora11
  kernel: latest mmotm

  cgroup size: 128M
  guest mem: 256M
  CONFIG_KSM=3Dn

My result,
  - plenty anon and file fault happen. but it is ideal. it is caused
by demand paging.
  - do_anonymous_page almost doesn't handle stack fault. both host and gues=
t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
