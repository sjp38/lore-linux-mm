Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id CE5106B005D
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 01:13:33 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id dn14so1415010obc.2
        for <linux-mm@kvack.org>; Thu, 10 Jan 2013 22:13:33 -0800 (PST)
Date: Thu, 10 Jan 2013 22:09:59 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130111060959.GA22981@lizard.gateway.2wire.net>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <20130108084949.GD4714@blaptop>
 <20130109221449.GA14880@lizard.fhda.edu>
 <20130111051210.GC6183@blaptop>
 <20130111053831.GA18053@lizard.gateway.2wire.net>
 <20130111055614.GD6183@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130111055614.GD6183@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, Jan 11, 2013 at 02:56:15PM +0900, Minchan Kim wrote:
[...]
> > Ahh. You're talking about the shrinker interface. Yes, there is no way to
> > tell if the freed memory will be actually "released" (and if not, then
> > yes, we released it unnecessary).
> 
> I don't tell about actually "released" or not.
> I assume application actually release pages but the pages would be another
> zones, NOT targetted zone from kernel. In case of that, kernel could ask
> continuously until target zone has enough free memory.
[...]
> > isolate task to only some nodes/zones, if we really care about precise
> > accounting?). But I'm surely open for ideas. :)
> 
> My dumb idea is only notify to user when reclaim is triggered by
> __GFP_HIGHMEM|__GFP_MOVABLE which is most gfp_t for application memory. :)

Ah, I see. Sure, that will help a lot. I'll try to incorporate this into
the next iteration. But there are still unresolved accounting issues that
I outlined, and I don't think that they are this easy to solve. :)

Thanks!

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
