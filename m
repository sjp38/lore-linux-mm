Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0284A6B0253
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 10:41:31 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id g73so59305365ioe.3
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 07:41:30 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id lp5si31681602igb.64.2016.01.21.07.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jan 2016 07:41:30 -0800 (PST)
Date: Thu, 21 Jan 2016 09:41:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat: make vmstat_updater deferrable again and shut down on
 idle
In-Reply-To: <CAPub14_S6swU_SPzZjx_OwyWhPBzXsfaoQ4Xc4qAKTDbtmjPSA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1601210940030.7063@east.gentwo.org>
References: <alpine.DEB.2.20.1512101441140.19122@east.gentwo.org> <CAPub148GRFho0oS9Vf0UdX+2Q84+031DE7jKj6Nxc0o0ZqWEmA@mail.gmail.com> <alpine.DEB.2.20.1601200910480.21388@east.gentwo.org>
 <CAPub14_S6swU_SPzZjx_OwyWhPBzXsfaoQ4Xc4qAKTDbtmjPSA@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shiraz Hashim <shiraz.linux.kernel@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp

On Thu, 21 Jan 2016, Shiraz Hashim wrote:

> > On idle we fold counters immediately. So there is no loss of accuracy.
>
> vmstat is scheduled by shepherd or by itself (conditionally). In case shepherd
> is deferred and vmstat doesn't schedule itself, then vmstat needs to wait
> for shepherd to be up and then schedule it. This may end up in delayed status
> update for all live cpus. Isn't it ?

The shepherd runs on a processor with an active tick and thus should do
its duty every 2 seconds as scheduled. Small milisecond range deferrals do
not matter much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
