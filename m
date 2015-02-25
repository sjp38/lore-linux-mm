Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 157FC6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:51:45 -0500 (EST)
Received: by padet14 with SMTP id et14so8354429pad.11
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:51:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qe4si13712271pdb.150.2015.02.25.13.51.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 13:51:44 -0800 (PST)
Date: Wed, 25 Feb 2015 13:51:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: __GFP_NOFAIL and oom_killer_disabled?
Message-Id: <20150225135143.caa950fc147d9241bf23ae32@linux-foundation.org>
In-Reply-To: <201502260648.IBC35479.QMVHOtFOJSFFLO@I-love.SAKURA.ne.jp>
References: <20150223102147.GB24272@dhcp22.suse.cz>
	<201502232203.DGC60931.QVtOLSOOJFMHFF@I-love.SAKURA.ne.jp>
	<20150224181408.GD14939@dhcp22.suse.cz>
	<201502252022.AAH51015.OtHLOVFJSMFFQO@I-love.SAKURA.ne.jp>
	<20150225160223.GH26680@dhcp22.suse.cz>
	<201502260648.IBC35479.QMVHOtFOJSFFLO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@suse.cz, hannes@cmpxchg.org, tytso@mit.edu, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org

On Thu, 26 Feb 2015 06:48:02 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:

> > OK, that would change the bahavior for __GFP_NOFAIL|~__GFP_FS
> > allocations. The patch from Johannes which reverts GFP_NOFS failure mode
> > should go to stable and that should be sufficient IMO.
> >  
> 
> mm-page_alloc-revert-inadvertent-__gfp_fs-retry-behavior-change.patch
> fixes only ~__GFP_NOFAIL|~__GFP_FS case. I think we need David's version
> http://marc.info/?l=linux-mm&m=142489687015873&w=2 for 3.19-stable .

afacit nobody has even tested that.  If we want changes made to 3.19.x
then they will need to be well tested, well changelogged and signed off. 
Please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
