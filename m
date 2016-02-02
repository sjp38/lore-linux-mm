Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 22ACD6B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 01:29:48 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id ho8so95732732pac.2
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 22:29:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kg1si29339164pad.81.2016.02.01.22.29.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 22:29:47 -0800 (PST)
Date: Mon, 1 Feb 2016 22:32:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmpressure: Fix subtree pressure detection
Message-Id: <20160201223236.d7393b62.akpm@linux-foundation.org>
In-Reply-To: <20160129083749.GB4952@esperanza>
References: <1453912137-25473-1-git-send-email-vdavydov@virtuozzo.com>
	<20160128155531.GE15948@dhcp22.suse.cz>
	<56AA6AEE.30004@suse.cz>
	<20160129083749.GB4952@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 29 Jan 2016 11:37:49 +0300 Vladimir Davydov <vdavydov@virtuozzo.com> wrote:

> On Thu, Jan 28, 2016 at 08:24:30PM +0100, Vlastimil Babka wrote:
> > On 28.1.2016 16:55, Michal Hocko wrote:
> > > On Wed 27-01-16 19:28:57, Vladimir Davydov wrote:
> > >> When vmpressure is called for the entire subtree under pressure we
> > >> mistakenly use vmpressure->scanned instead of vmpressure->tree_scanned
> > >> when checking if vmpressure work is to be scheduled. This results in
> > >> suppressing all vmpressure events in the legacy cgroup hierarchy. Fix
> > >> it.
> > >>
> > >> Fixes: 8e8ae645249b ("mm: memcontrol: hook up vmpressure to socket pressure")
> > >> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> > > 
> > > a = b += c made me scratch my head for a second but this looks correct
> > 
> > Ugh, it's actually a = b += a
> > 
> > While clever and compact, this will make scratch their head anyone looking at
> > the code in the future. Is it worth it?
> 
> I'm just trying to be consistend with the !tree case, where we do
> exactly the same.

I stared suspiciously at it for a while, decided to let it go. 
Possibly we can remove local `scanned' altogether.  No matter, someone
will clean it all up sometime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
