Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 01B956B0254
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 15:55:12 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id y89so126117965qge.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:55:11 -0800 (PST)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id h86si27533303qkh.25.2016.02.29.12.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 12:55:11 -0800 (PST)
Received: by mail-qk0-x233.google.com with SMTP id s5so61574924qkd.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:55:11 -0800 (PST)
Date: Mon, 29 Feb 2016 15:55:09 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: reset memory.low on css offline
Message-ID: <20160229205509.GW3965@htj.duckdns.org>
References: <1456766193-16255-1-git-send-email-vdavydov@virtuozzo.com>
 <20160229200255.GA32539@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229200255.GA32539@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Hello,

On Mon, Feb 29, 2016 at 03:02:55PM -0500, Johannes Weiner wrote:
> > To fix this, let's reset memory.low on css offline.
> 
> We already have mem_cgroup_css_reset() for soft-offlining a css - when
> the css is asked to be disabled but another subsystem still uses it.
> Can we just call that function during offline as well? The css can be
> around for quite a bit after the user deleted it. Eliminating *any*
> user-supplied configurations and zapping it back to defaults makes
> sense in general, so that we never have to worry about any remnants.

Hmmm... I wonder whether the behavior can be a bit surprising and it
could be better to simply let memcg offline callback to call the reset
function explicitly.  No big deal either way tho.  Please feel free to
send a patch.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
