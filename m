Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4B86B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 04:38:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c5so18393226wmi.0
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 01:38:54 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.21])
        by mx.google.com with ESMTPS id 1si5883635wrh.331.2017.03.23.01.38.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 01:38:53 -0700 (PDT)
Message-ID: <1490258325.27756.42.camel@gmx.de>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
From: Mike Galbraith <efault@gmx.de>
Date: Thu, 23 Mar 2017 09:38:45 +0100
In-Reply-To: <1ce2621b-0573-0cc7-a1df-49d6c68df792@wiesinger.com>
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
	 <1490080422.14658.39.camel@gmx.de>
	 <1ce2621b-0573-0cc7-a1df-49d6c68df792@wiesinger.com>
Content-Type: text/plain; charset="us-ascii"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>, Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, 2017-03-23 at 08:16 +0100, Gerhard Wiesinger wrote:
> On 21.03.2017 08:13, Mike Galbraith wrote:
> > On Tue, 2017-03-21 at 06:59 +0100, Gerhard Wiesinger wrote:
> > 
> > > Is this the correct information?
> > Incomplete, but enough to reiterate cgroup_disable=memory
> > suggestion.
> > 
> 
> How to collect complete information?

If Michal wants specifics, I suspect he'll ask.  I posted only to pass
along a speck of information, and offer a test suggestion.. twice.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
