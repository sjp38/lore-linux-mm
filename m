Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 73DB96B0062
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 17:51:34 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id rl6so6291452pac.1
        for <linux-mm@kvack.org>; Fri, 28 Dec 2012 14:51:33 -0800 (PST)
Date: Fri, 28 Dec 2012 14:48:01 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [announce] Timeout Based User-space Low Memory Killer Daemon
Message-ID: <20121228224800.GA14273@lizard.sbx05280.losalca.wayport.net>
References: <201212281527.43430.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <201212281527.43430.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, John Stultz <john.stultz@linaro.org>

On Fri, Dec 28, 2012 at 03:27:43PM +0100, Bartlomiej Zolnierkiewicz wrote:
> 
> Hi,
> 
> I would like to announce the first public version of my timeout based
> user-space low memory killer daemon (tbulmkd).  It is based on idea
> that user-space applications can be divided into two classes,
> foreground and background ones.  Foreground processes are visible in
> graphical user interface (GUI) and therefore shouldn't be terminated
> first when memory usage gets too high.  OTOH background processes are
> no longer visible in GUI and are pro-actively being killed to keep
> overall memory usage smaller.  Actual daemon implementation is heavily
> based on the user-space low memory killer daemon (ulmkd) from Anton
> Vorontsov (http://thread.gmane.org/gmane.linux.kernel.mm/84302).
> 
> The program is available at:
> 
> 	https://github.com/bzolnier/tbulmkd

Wow, that's so great. Now it seems more like an Activity Manager.

I didn't look very close to it, but I see that you extensively use cgroups
to actually group the processes, i.e. 'daemons' cgroup, 'apps' cgroup.

So, it might be a very good start for truly cross-platform, truly generic
way to implement Activity Manager. :)

I'm surely interested in how it evolves, and will take a closer look soon.

Thanks!

> kernel/add-tbulmkd-entries.patch needs to be applied to the kernel
> that would be used with tbulmkd.  It adds /proc/$pid/activity and
> /proc/$pid/activity_time files.  Write '0' to activity file to mark
> the process as background one and '1' (the default value) to mark
> it as foreground one.  Please note that this interface is just for
> a demonstration of tbulmkd functionality and will be changed in
> the future.
> 
> Best regards,
> --
> Bartlomiej Zolnierkiewicz
> Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
