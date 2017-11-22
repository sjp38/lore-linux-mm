Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24E976B0273
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:34:02 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id d14so10052962wrg.15
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:34:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p88si1482142edd.543.2017.11.22.04.34.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 04:34:00 -0800 (PST)
Date: Wed, 22 Nov 2017 13:33:56 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
Message-ID: <20171122123356.drb7xppha7i3rsze@dhcp22.suse.cz>
References: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171121134007.466815aa4a0562eaaa223cbf@linux-foundation.org>
 <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, david@fromorbit.com, viro@zeniv.linux.org.uk, jack@suse.com, pbonzini@redhat.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

On Wed 22-11-17 07:09:33, Tetsuo Handa wrote:
> Andrew Morton wrote:
[...]
> > I'm not sure this is worth bothering about?
> > 
> 
> Continuing with failed register_shrinker() is almost always wrong.
> Though I don't know whether mm/zsmalloc.c case can make sense.

Well, strictly speaking ignoring an error from _any_ function is almost
always wrong. So I am not sure why __must_check is actually an
improvement.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
