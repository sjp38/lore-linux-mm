Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1974D6B0262
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 10:58:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r5so7790313wmr.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:58:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p7si32238727wmd.23.2016.06.08.07.58.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 07:58:41 -0700 (PDT)
Date: Wed, 8 Jun 2016 10:58:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: remove BUG_ON in uncharge_list
Message-ID: <20160608145833.GA6727@cmpxchg.org>
References: <1465369248-13865-1-git-send-email-roy.qing.li@gmail.com>
 <20160608072554.GD22570@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160608072554.GD22570@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, roy.qing.li@gmail.com, vdavydov@virtuozzo.com

On Wed, Jun 08, 2016 at 09:25:54AM +0200, Michal Hocko wrote:
> On Wed 08-06-16 15:00:48, roy.qing.li@gmail.com wrote:
> > From: Li RongQing <roy.qing.li@gmail.com>
> > 
> > when call uncharge_list, if a page is transparent huge, and not need to
> > BUG_ON about non-transparent huge, since nobody should be be seeing the
> > page at this stage and this page cannot be raced with a THP split up
> 
> Johannes do you remember why you have kept this bug on even after
> 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API")?

No, I just copied it over without thinking too much about it. That
patch was pretty drastic, so why not keep the sanity checks in case
one of the many assumptions it made were flawed...

But it's probably okay to drop it at this point.

> > Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
