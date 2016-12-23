Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E25628026F
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 07:57:33 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so40756629wms.7
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 04:57:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o123si31949393wmd.160.2016.12.23.04.57.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Dec 2016 04:57:32 -0800 (PST)
Date: Fri, 23 Dec 2016 13:57:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161223125728.GE23109@dhcp22.suse.cz>
References: <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
 <20161217210646.GA11358@boerne.fritz.box>
 <20161219134534.GC5164@dhcp22.suse.cz>
 <20161220020829.GA5449@boerne.fritz.box>
 <20161221073658.GC16502@dhcp22.suse.cz>
 <20161222101028.GA11105@ppc-nas.fritz.box>
 <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161223121851.GA27413@ppc-nas.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Fri 23-12-16 13:18:51, Nils Holland wrote:
> On Fri, Dec 23, 2016 at 11:51:57AM +0100, Michal Hocko wrote:
> > TL;DR
> > drop the last patch, check whether memory cgroup is enabled and retest
> > with cgroup_disable=memory to see whether this is memcg related and if
> > it is _not_ then try to test with the patch below
> 
> Right, it seems we might be looking in the right direction! So I
> removed the previous patch from my kernel and verified if memory
> cgroup was enabled, and indeed, it was. So I booted with
> cgroup_disable=memory and ran my ordinary test again ... and in fact,
> no ooms!

OK, thanks for confirmation. I could have figured that earlier. The
pagecache differences in such a short time should have raised the red
flag and point towards memcgs...

[...]
> > I would appreciate to stick with your setup to not pull new unknows into
> > the picture.
> 
> No problem! It's just likely that I won't be able to test during the
> following days until Dec 27th, but after that I should be back to
> normal and thus be able to run further tests in a timely fashion. :-)

no problem at all. I will try to cook up a patch in the mean time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
