Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3714A6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 03:17:04 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so101538583lfg.5
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 00:17:04 -0700 (PDT)
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id a201si2808493lfe.49.2017.03.23.00.17.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 00:17:02 -0700 (PDT)
From: Gerhard Wiesinger <lists@wiesinger.com>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
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
Message-ID: <1ce2621b-0573-0cc7-a1df-49d6c68df792@wiesinger.com>
Date: Thu, 23 Mar 2017 08:16:54 +0100
MIME-Version: 1.0
In-Reply-To: <1490080422.14658.39.camel@gmx.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>, Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 21.03.2017 08:13, Mike Galbraith wrote:
> On Tue, 2017-03-21 at 06:59 +0100, Gerhard Wiesinger wrote:
>
>> Is this the correct information?
> Incomplete, but enough to reiterate cgroup_disable=memory suggestion.
>

How to collect complete information?

Thnx.

Ciao,
Gerhard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
