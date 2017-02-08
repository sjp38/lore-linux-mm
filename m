Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA716B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 10:06:52 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 101so147817298iom.7
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 07:06:52 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id q135si14916219iod.130.2017.02.08.07.06.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 07:06:51 -0800 (PST)
Date: Wed, 8 Feb 2017 09:06:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <alpine.DEB.2.20.1702072319200.8117@nanos>
Message-ID: <alpine.DEB.2.20.1702080906100.3955@east.gentwo.org>
References: <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz> <20170207102809.awh22urqmfrav5r6@techsingularity.net> <20170207103552.GH5065@dhcp22.suse.cz> <20170207113435.6xthczxt2cx23r4t@techsingularity.net> <20170207114327.GI5065@dhcp22.suse.cz>
 <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz> <20170207162224.elnrlgibjegswsgn@techsingularity.net> <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org> <alpine.DEB.2.20.1702072319200.8117@nanos>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 7 Feb 2017, Thomas Gleixner wrote:

> > Yep. Hotplug events are pretty significant. Using stop_machine_XXXX() etc
> > would be advisable and that would avoid the taking of locks and get rid of all the
> > ocmplexity, reduce the code size and make the overall system much more
> > reliable.
>
> Huch? stop_machine() is horrible and heavy weight. Don't go there, there
> must be simpler solutions than that.

Inserting or removing hardware is a heavy process. This would help quite a
bit with these issues for loops over active cpus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
