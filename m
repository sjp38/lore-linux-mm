Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EE4F58D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 03:41:37 -0500 (EST)
Received: by fxm12 with SMTP id 12so3601608fxm.14
        for <linux-mm@kvack.org>; Fri, 18 Feb 2011 00:41:34 -0800 (PST)
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <m17hcx7wca.fsf@fess.ebiederm.org>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
	 <20110216193700.GA6377@elte.hu>
	 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
	 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
	 <20110217090910.GA3781@tiehlicka.suse.cz>
	 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	 <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	 <m1sjvm822m.fsf@fess.ebiederm.org>
	 <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
	 <m17hcx7wca.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Feb 2011 09:41:25 +0100
Message-ID: <1298018485.2595.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Octavian Purdila <opurdila@ixiacom.com>, David Miller <davem@davemloft.net>, Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

So I confirm previous kernels had a bug too in rollback_registered()

The "single" list was left as is before exiting.

default_device_exit_batch() seems OK, because the rtnl_unlock() acted as
a barrier in this respect : devices were removed from dev_kill_list
before exiting default_device_exit_batch()

Following this mail, please find two patches.

One from Linus to address bug introduced in commit 443457242beb6
(net: factorize
sync-rcu call in unregister_netdevice_many) in 2.6.38-rc1

A second one to address old bugs, so that stable teams can fix previous
kernels (2.6.33 and up)
Offending commit was 9b5e383c11b08784 (net: Introduce
unregister_netdevice_many())

Of course this second patch is also needed for current linux-2.6

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
