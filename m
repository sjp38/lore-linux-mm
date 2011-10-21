Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C40C6B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 12:11:46 -0400 (EDT)
Received: by eye4 with SMTP id 4so5546196eye.14
        for <linux-mm@kvack.org>; Fri, 21 Oct 2011 09:11:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111020105950.fd04f58f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111020013305.GD21703@tiehlicka.suse.cz>
	<20111020105950.fd04f58f.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 21 Oct 2011 21:41:43 +0530
Message-ID: <CAKTCnz=0VcM9zi2Apv0YOrYPRqe6Cmm_QDcBj5t2nMo1=f9+Og@mail.gmail.com>
Subject: Re: [RFD] Isolated memory cgroups again
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@hansenpartnership.com>

> But I personally think we should make softlimit better rather than
> adding new interface. If this feature can be archieved when setting
> softlimit=UNLIMITED, it's simple. And Johannes' work will make this
> easy to be implemented.
> (total rewrite of softlimit should be required...I think.)
>

Yeah.. I'd be open to a rewrite if we get the specification/design
right. I did soft limits in a few months and tested it on workloads
till I was satisfied it worked.

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
