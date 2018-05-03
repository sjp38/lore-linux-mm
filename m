Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1746B0005
	for <linux-mm@kvack.org>; Thu,  3 May 2018 09:03:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b64so15194149pfl.13
        for <linux-mm@kvack.org>; Thu, 03 May 2018 06:03:00 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0101.outbound.protection.outlook.com. [104.47.37.101])
        by mx.google.com with ESMTPS id v7-v6si13961175plp.31.2018.05.03.06.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 May 2018 06:02:56 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Thu, 3 May 2018 13:02:52 +0000
Message-ID: <20180503130246.GF18390@sasha-vm>
References: <20180416211845.GP2341@sasha-vm>
 <nycvar.YFH.7.76.1804162326210.28129@cbobk.fhfr.pm>
 <20180417103936.GC8445@kroah.com> <20180417110717.GB17484@dhcp22.suse.cz>
 <20180417140434.GU2341@sasha-vm> <20180417143631.GI17484@dhcp22.suse.cz>
 <20180417145531.GW2341@sasha-vm>
 <nycvar.YFH.7.76.1804171742450.28129@cbobk.fhfr.pm>
 <20180417160627.GX2341@sasha-vm> <20180503100441.GE32180@amd>
In-Reply-To: <20180503100441.GE32180@amd>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8E6010D53D94404FBD8E0CB0E73B6235@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Jiri Kosina <jikos@kernel.org>, Michal Hocko <mhocko@kernel.org>, Greg KH <greg@kroah.com>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Thu, May 03, 2018 at 12:04:41PM +0200, Pavel Machek wrote:
>On Tue 2018-04-17 16:06:29, Sasha Levin wrote:
>> On Tue, Apr 17, 2018 at 05:52:30PM +0200, Jiri Kosina wrote:
>> >On Tue, 17 Apr 2018, Sasha Levin wrote:
>> >
>> >> How do I get the XFS folks to send their stuff to -stable? (we have
>> >> quite a few customers who use XFS)
>> >
>> >If XFS (or *any* other subsystem) doesn't have enough manpower of upstr=
eam
>> >maintainers to deal with stable, we just have to accept that and find a=
n
>> >answer to that.
>>
>> This is exactly what I'm doing. Many subsystems don't have enough
>> manpower to deal with -stable, so I'm trying to help.
>
>...and the torrent of spams from the AUTOSEL subsystem actually makes
>that worse.
>
>And when you are told particular fix to LEDs is not that important
>after all, you start arguing about nuclear power plants (without
>really knowing how critical subsystems work).

Obviously your knowledge far surpasses mine.

>If you want cooperation with maintainers to work, the rules need to be
>clear, first. They are documented, so follow them. If you think rules
>are wrong, lets talk about changing the rules; but arguing "every bug
>is important because someone may be hitting it" is not ok.

I'm sorry but you're just unfamiliar with the process. I'd point out
that all my AUTOSEL commits go through Greg, who wrote the rules, and
accepts my patches.

The rules are there as a guideline to allow us to not take certain
patches, they're not there as a strict set of rules we must follow at
all times.=
