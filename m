Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 013BA6B0038
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 10:04:18 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 192so41360200itm.1
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 07:04:17 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0086.outbound.protection.outlook.com. [104.47.0.86])
        by mx.google.com with ESMTPS id k126si2389404oif.49.2016.09.02.07.04.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 02 Sep 2016 07:04:09 -0700 (PDT)
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com>
 <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
 <20160830075854.GZ10153@twins.programming.kicks-ass.net>
 <a321c8a7-fa9c-21f7-61f8-54a8f80763fe@mellanox.com>
 <20160901100631.GQ10153@twins.programming.kicks-ass.net>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <ee883e4b-6f5a-6025-e505-76c6b8db4e76@mellanox.com>
Date: Fri, 2 Sep 2016 10:03:52 -0400
MIME-Version: 1.0
In-Reply-To: <20160901100631.GQ10153@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On 9/1/2016 6:06 AM, Peter Zijlstra wrote:
> On Tue, Aug 30, 2016 at 11:32:16AM -0400, Chris Metcalf wrote:
>> On 8/30/2016 3:58 AM, Peter Zijlstra wrote:
>>> What !? I really don't get this, what are you waiting for? Why is
>>> rescheduling making things better.
>> We need to wait for the last dyntick to fire before we can return to
>> userspace.  There are plenty of options as to what we can do in the
>> meanwhile.
> Why not keep your _TIF_TASK_ISOLATION_FOO flag set and re-enter the
> loop?
>
> I really don't see how setting TIF_NEED_RESCHED is helping anything.

Yes, I think I addressed that in an earlier reply to Frederic; and you're right,
I don't think TIF_NEED_RESCHED or schedule() are the way to go.

https://lkml.kernel.org/g/107bd666-dbcf-7fa5-ff9c-f79358899712@mellanox.com

Any thoughts on the question of "just re-enter the loop" vs. schedule_timeout()?

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
