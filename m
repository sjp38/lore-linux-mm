Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id EAC8D6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:12:54 -0500 (EST)
Received: by mail-io0-f180.google.com with SMTP id 77so22469920ioc.2
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:12:54 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id y20si18616034igr.26.2016.01.20.07.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 07:12:54 -0800 (PST)
Date: Wed, 20 Jan 2016 09:12:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat: make vmstat_updater deferrable again and shut down on
 idle
In-Reply-To: <CAPub148GRFho0oS9Vf0UdX+2Q84+031DE7jKj6Nxc0o0ZqWEmA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1601200910480.21388@east.gentwo.org>
References: <alpine.DEB.2.20.1512101441140.19122@east.gentwo.org> <CAPub148GRFho0oS9Vf0UdX+2Q84+031DE7jKj6Nxc0o0ZqWEmA@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shiraz Hashim <shiraz.linux.kernel@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp

On Wed, 20 Jan 2016, Shiraz Hashim wrote:

> The patch makes vmstat_shepherd deferable which if is quiesed
> would not schedule vmstat update on other cpus. Wouldn't this
> aggravate the problem of vmstat for rest cpus not gettng updated.

Its only "deferred" in order to make it at the next tick and not cause an
extra event. This means that vmstat will run periodically from tick
processing. It merely causes a synching so that we have one interruption
that does both.

On idle we fold counters immediately. So there is no loss of accuracy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
