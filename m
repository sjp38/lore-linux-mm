Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 577D76B0007
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 01:58:11 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s6so1471277pgn.16
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 22:58:11 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x4si2327963pgv.549.2018.04.18.22.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 22:58:10 -0700 (PDT)
Date: Thu, 19 Apr 2018 13:58:03 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: WARNING: stack going in the wrong direction?
 ip=__schedule+0x489/0x830
Message-ID: <20180419055803.ty5nxeb36qwoywi7@wfg-t540p.sh.intel.com>
References: <20180419054941.hpmfbyybqhlscghh@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180419054941.hpmfbyybqhlscghh@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Luca Abeni <luca.abeni@santannapisa.it>, Nicolas Pitre <nicolas.pitre@linaro.org>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-kernel@vger.kernel.org, lkp@01.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Huang Ying <ying.huang@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, LKP <lkp@intel.com>, Philip Li <philip.li@intel.com>

On Thu, Apr 19, 2018 at 01:49:41PM +0800, Fengguang Wu wrote:
>Hello,
>
>FYI this warning dates back to v4.16-rc5 .

>It's rather rare and often happen together with other errors.

Sorry, that should be 0day didn't catch this particular WARNING.
So it just occasionally show up in the context of other errors.

I jut added that WARNING pattern to 0day and hope we can get more
information about it.

Thanks,
Fengguang
