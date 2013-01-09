Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 365686B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 17:18:22 -0500 (EST)
Received: by mail-da0-f54.google.com with SMTP id n2so961425dad.41
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 14:18:21 -0800 (PST)
Date: Wed, 9 Jan 2013 14:14:49 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130109221449.GA14880@lizard.fhda.edu>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <20130108084949.GD4714@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130108084949.GD4714@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, Jan 08, 2013 at 05:49:49PM +0900, Minchan Kim wrote:
[...]
> Sorry still I didn't look at your implementation about cgroup part.
> but I had a question since long time ago.
> 
> How can we can make sure false positive about zone and NUMA?
> I mean DMA zone is short in system so VM notify to user and user
> free all memory of NORMAL zone because he can't know what pages live
> in any zones. NUMA is ditto.

Um, we count scans irrespective of zones or nodes, i.e. we sum all 'number
of scanned' and 'number of reclaimed' stats. So, it should not be a
problem, as I see it.

Thanks,
Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
