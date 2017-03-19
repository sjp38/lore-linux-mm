Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E86936B0038
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 04:17:42 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p85so59483919lfg.5
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 01:17:42 -0700 (PDT)
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id i88si7237110lfk.387.2017.03.19.01.17.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 01:17:41 -0700 (PDT)
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
References: <20170228051723.GD2702@bbox>
 <20170228081223.GA26792@dhcp22.suse.cz> <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
 <20170316092318.GQ802@shells.gnugeneration.com>
 <20170316093931.GH30501@dhcp22.suse.cz>
 <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
 <20170317171339.GA23957@dhcp22.suse.cz>
 <8cb1d796-aff3-0063-3ef8-880e76d437c0@wiesinger.com>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <62c22eea-c65c-5a9b-0de6-3a7a916ec7f0@wiesinger.com>
Date: Sun, 19 Mar 2017 09:17:26 +0100
MIME-Version: 1.0
In-Reply-To: <8cb1d796-aff3-0063-3ef8-880e76d437c0@wiesinger.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 17.03.2017 21:08, Gerhard Wiesinger wrote:
> On 17.03.2017 18:13, Michal Hocko wrote:
>> On Fri 17-03-17 17:37:48, Gerhard Wiesinger wrote:
>> [...] 

4.11.0-0.rc2.git4.1.fc27.x86_64

There are also lockups after some runtime hours to 1 day:
Message from syslogd@myserver Mar 19 08:22:33 ...
  kernel:BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 
stuck for 18717s!

Message from syslogd@myserver at Mar 19 08:22:33 ...
  kernel:BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 
stuck for 18078s!

repeated a lot of times ....

Ciao,
Gerhard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
