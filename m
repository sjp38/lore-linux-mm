Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B84D06B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 05:41:04 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id x16so1475880pfe.20
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 02:41:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si8124875pgr.379.2018.01.19.02.41.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 02:41:03 -0800 (PST)
Date: Fri, 19 Jan 2018 11:40:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] Per file OOM badness
Message-ID: <20180119104058.GU6584@dhcp22.suse.cz>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz>
 <20180118171355.GH6584@dhcp22.suse.cz>
 <87k1wfgcmb.fsf@anholt.net>
 <20180119082046.GL6584@dhcp22.suse.cz>
 <0cfaf256-928c-4cb8-8220-b8992592071b@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0cfaf256-928c-4cb8-8220-b8992592071b@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Cc: Eric Anholt <eric@anholt.net>, Andrey Grodzovsky <andrey.grodzovsky@amd.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org

On Fri 19-01-18 09:39:03, Christian Konig wrote:
> Am 19.01.2018 um 09:20 schrieb Michal Hocko:
[...]
> > OK, in that case I would propose a different approach. We already
> > have rss_stat. So why do not we simply add a new counter there
> > MM_KERNELPAGES and consider those in oom_badness? The rule would be
> > that such a memory is bound to the process life time. I guess we will
> > find more users for this later.
> 
> I already tried that and the problem with that approach is that some buffers
> are not created by the application which actually uses them.
> 
> For example X/Wayland is creating and handing out render buffers to
> application which want to use OpenGL.
> 
> So the result is when you always account the application who created the
> buffer the OOM killer will certainly reap X/Wayland first. And that is
> exactly what we want to avoid here.

Then you have to find the target allocation context at the time of the
allocation and account it. As follow up emails show, implementations
might differ and any robust oom solution have to rely on the common
counters.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
