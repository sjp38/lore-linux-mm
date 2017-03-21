Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3708D6B0388
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 03:13:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u108so30696505wrb.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 00:13:50 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id z15si26551507wrb.95.2017.03.21.00.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 00:13:49 -0700 (PDT)
Message-ID: <1490080422.14658.39.camel@gmx.de>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
From: Mike Galbraith <efault@gmx.de>
Date: Tue, 21 Mar 2017 08:13:42 +0100
In-Reply-To: <798104b6-091d-5415-2c51-8992b6b231e5@wiesinger.com>
References: <20170302071721.GA32632@bbox>
	 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
	 <20170316082714.GC30501@dhcp22.suse.cz>
	 <20170316084733.GP802@shells.gnugeneration.com>
	 <20170316090844.GG30501@dhcp22.suse.cz>
	 <20170316092318.GQ802@shells.gnugeneration.com>
	 <20170316093931.GH30501@dhcp22.suse.cz>
	 <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
	 <20170317171339.GA23957@dhcp22.suse.cz>
	 <8cb1d796-aff3-0063-3ef8-880e76d437c0@wiesinger.com>
	 <20170319151837.GD12414@dhcp22.suse.cz>
	 <555d1f95-7c9e-2691-b14f-0260f90d23a9@wiesinger.com>
	 <1489979147.4273.22.camel@gmx.de>
	 <798104b6-091d-5415-2c51-8992b6b231e5@wiesinger.com>
Content-Type: text/plain; charset="us-ascii"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>, Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 2017-03-21 at 06:59 +0100, Gerhard Wiesinger wrote:

> Is this the correct information?

Incomplete, but enough to reiterate cgroup_disable=memory suggestion.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
