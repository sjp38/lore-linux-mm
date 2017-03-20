Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 706236B0038
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 23:12:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y90so24471521wrb.1
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 20:12:45 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id a17si13099656wma.59.2017.03.19.20.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 20:12:44 -0700 (PDT)
Message-ID: <1489979147.4273.22.camel@gmx.de>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
From: Mike Galbraith <efault@gmx.de>
Date: Mon, 20 Mar 2017 04:05:47 +0100
In-Reply-To: <555d1f95-7c9e-2691-b14f-0260f90d23a9@wiesinger.com>
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
Content-Type: text/plain; charset="us-ascii"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>, Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, 2017-03-19 at 17:02 +0100, Gerhard Wiesinger wrote:

> mount | grep cgroup

Just because controllers are mounted doesn't mean they're populated. To
check that, you want to look for directories under the mount points
with a non-empty 'tasks'.  You will find some, but memory cgroup
assignments would likely be most interesting for this thread.  You can
eliminate any diddling there by booting with cgroup_disable=memory.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
