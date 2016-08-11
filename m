Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FDBA6B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 15:03:26 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id m12so2314668ybm.3
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 12:03:26 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [69.252.207.35])
        by mx.google.com with ESMTPS id n14si1083067qkl.2.2016.08.11.12.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 12:03:25 -0700 (PDT)
Date: Thu, 11 Aug 2016 13:50:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v14 04/14] task_isolation: add initial support
In-Reply-To: <20160811181132.GD4214@lerouge>
Message-ID: <alpine.DEB.2.20.1608111349190.1644@east.gentwo.org>
References: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com> <1470774596-17341-5-git-send-email-cmetcalf@mellanox.com> <20160811181132.GD4214@lerouge>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Chris Metcalf <cmetcalf@mellanox.com>, Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 11 Aug 2016, Frederic Weisbecker wrote:

> Do we need to quiesce vmstat everytime before entering userspace?
> I thought that vmstat only need to be offlined once and for all?

Once is sufficient after disabling the tick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
