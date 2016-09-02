Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9EA56B0069
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 12:40:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c132so132570505pfg.2
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 09:40:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id pw10si12213944pab.243.2016.09.02.09.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Sep 2016 09:40:14 -0700 (PDT)
Date: Fri, 2 Sep 2016 18:40:04 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
Message-ID: <20160902164004.GJ10153@twins.programming.kicks-ass.net>
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com>
 <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
 <20160830075854.GZ10153@twins.programming.kicks-ass.net>
 <a321c8a7-fa9c-21f7-61f8-54a8f80763fe@mellanox.com>
 <20160901100631.GQ10153@twins.programming.kicks-ass.net>
 <ee883e4b-6f5a-6025-e505-76c6b8db4e76@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ee883e4b-6f5a-6025-e505-76c6b8db4e76@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Sep 02, 2016 at 10:03:52AM -0400, Chris Metcalf wrote:
> Any thoughts on the question of "just re-enter the loop" vs. schedule_timeout()?

schedule_timeout() should only be used for things you do not have
control over, like things outside of the machine.

If you want to actually block running, use that completion you were
talking of.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
