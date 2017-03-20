Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 436056B0038
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 21:54:23 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 21so95373535pgg.4
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 18:54:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y10si11197897pfk.375.2017.03.19.18.54.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 18:54:22 -0700 (PDT)
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
 <62c22eea-c65c-5a9b-0de6-3a7a916ec7f0@wiesinger.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <eccd9828-803b-1f2a-d3ed-dea59a1e00cd@I-love.SAKURA.ne.jp>
Date: Mon, 20 Mar 2017 10:54:12 +0900
MIME-Version: 1.0
In-Reply-To: <62c22eea-c65c-5a9b-0de6-3a7a916ec7f0@wiesinger.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: Michal Hocko <mhocko@kernel.org>, lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 2017/03/19 17:17, Gerhard Wiesinger wrote:
> On 17.03.2017 21:08, Gerhard Wiesinger wrote:
>> On 17.03.2017 18:13, Michal Hocko wrote:
>>> On Fri 17-03-17 17:37:48, Gerhard Wiesinger wrote:
>>> [...] 
> 
> 4.11.0-0.rc2.git4.1.fc27.x86_64
> 
> There are also lockups after some runtime hours to 1 day:
> Message from syslogd@myserver Mar 19 08:22:33 ...
>  kernel:BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 18717s!
> 
> Message from syslogd@myserver at Mar 19 08:22:33 ...
>  kernel:BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 18078s!
> 
> repeated a lot of times ....
> 
> Ciao,
> Gerhard

"kernel:BUG: workqueue lockup" lines alone do not help. It does not tell what work is
stalling. Maybe stalling due to constant swapping while doing memory allocation when
processing some work, but relevant lines are needed in order to know what is happening.
You can try SysRq-t to dump what workqueue threads are doing when you encounter such lines.

You might want to try kmallocwd at
http://lkml.kernel.org/r/1489578541-81526-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
