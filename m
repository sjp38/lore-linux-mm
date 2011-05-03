Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 482DB6B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 17:11:07 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Eliminate task stack trace duplication.
References: <1304444135-14128-1-git-send-email-yinghan@google.com>
	<m2iptref78.fsf@firstfloor.org>
	<BANLkTi=C9qpkfM1fjeCD_Z_-2rYUifiaUg@mail.gmail.com>
Date: Tue, 03 May 2011 14:10:57 -0700
In-Reply-To: <BANLkTi=C9qpkfM1fjeCD_Z_-2rYUifiaUg@mail.gmail.com> (Ying Han's
	message of "Tue, 3 May 2011 13:09:02 -0700")
Message-ID: <m2bozjebha.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

Ying Han <yinghan@google.com> writes:
>>
>> Also when you can't get it fall back to something else.
>
> Can you clarify that?

The debugging paths usually have a lock timeout and fall back
to not needing the lock (= not use a hash) when it expires.
This way you guarantee output even if the system
is already quite confused.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
