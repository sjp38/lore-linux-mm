Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 81BB3900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 20:27:08 -0400 (EDT)
Message-ID: <90769A9DD8A14AE8A5A08BAC24B1245F@jem>
From: "Rob Mueller" <robm@fastmail.fm>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104121659510.10966@chino.kir.corp.google.com>
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
Date: Wed, 13 Apr 2011 10:26:50 +1000
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


>> Recently, Robert Mueller reported zone_reclaim_mode doesn't work
>> properly on his new NUMA server (Dual Xeon E5520 + Intel S5520UR MB).
>> He is using Cyrus IMAPd and it's built on a very traditional
>> single-process model.
>>
>
> Let's add Robert to the cc to see if this is still an issue, it hasn't
> been re-reported in over six months.

We definitely still set this in /etc/sysctl.conf on every imap server 
machine:

vm.zone_reclaim_mode = 0

I believe it still defaults to 1 otherwise. What I haven't tested is if 
leaving it at 1 still causes problems. It definitely DID previously cause 
big problems (I think that was around 2.6.34 or so).

http://blog.fastmail.fm/2010/09/15/default-zone_reclaim_mode-1-on-numa-kernel-is-bad-for-fileemailweb-servers/

I'll try changing it to 1 on a machine for 4 hours, see if it makes a 
noticeable difference and report back.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
