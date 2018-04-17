Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7736B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:28:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d13so854107pfn.21
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:28:30 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0136.outbound.protection.outlook.com. [104.47.37.136])
        by mx.google.com with ESMTPS id h3si12042977pgf.257.2018.04.17.11.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 11:28:28 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Tue, 17 Apr 2018 18:28:27 +0000
Message-ID: <20180417182825.GA2341@sasha-vm>
References: <20180416161911.GA2341@sasha-vm>
 <20180416123019.4d235374@gandalf.local.home> <20180416163754.GD2341@sasha-vm>
 <20180416170604.GC11034@amd> <20180416172327.GK2341@sasha-vm>
 <20180417114144.ov27khlig5thqvyo@quack2.suse.cz>
 <20180417133149.GR2341@sasha-vm>
 <20180417155549.6lxmoiwnlwtwdgld@quack2.suse.cz>
 <20180417161933.GY2341@sasha-vm>
 <20180417175754.w4slhmwtf46hq3hm@quack2.suse.cz>
In-Reply-To: <20180417175754.w4slhmwtf46hq3hm@quack2.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <AC88667098D4EE4F8F033392BB9E4532@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, Apr 17, 2018 at 07:57:54PM +0200, Jan Kara wrote:
>Actually I was careful enough to include only commits that got merged as
>part of the stable process into 4.14.x but got later reverted in 4.14.y.
>That's where the 0.4% number came from. So I believe all of those cases
>(13 in absolute numbers) were user visible regressions during the stable
>process.

I looked at them, and there are 2 things in play here:

 - Quite a few of those reverts are because of the PTI work. I'm not
   sure how we treat it, but yes - it skews statistics here.
 - 2 of them were reverts for device tree changes for a device that
   didn't exist in 4.14, and shouldn't have had any user visible
   changes.=
