Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 986766B0069
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 11:55:56 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 101so117265167iom.7
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 08:55:56 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id e192si12249705iof.103.2017.02.07.08.55.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 08:55:55 -0800 (PST)
Date: Tue, 7 Feb 2017 10:55:51 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <20170207164130.GY5065@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org>
References: <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz> <20170207102809.awh22urqmfrav5r6@techsingularity.net> <20170207103552.GH5065@dhcp22.suse.cz> <20170207113435.6xthczxt2cx23r4t@techsingularity.net> <20170207114327.GI5065@dhcp22.suse.cz>
 <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz> <20170207162224.elnrlgibjegswsgn@techsingularity.net>
 <20170207164130.GY5065@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 7 Feb 2017, Michal Hocko wrote:

> I am always nervous when seeing hotplug locks being used in low level
> code. It has bitten us several times already and those deadlocks are
> quite hard to spot when reviewing the code and very rare to hit so they
> tend to live for a long time.

Yep. Hotplug events are pretty significant. Using stop_machine_XXXX() etc
would be advisable and that would avoid the taking of locks and get rid of all the
ocmplexity, reduce the code size and make the overall system much more
reliable.

Thomas?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
