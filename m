Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7EFAA6B007E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 07:31:29 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id o70so7764789lfg.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 04:31:29 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id h62si4334859wma.124.2016.05.24.04.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 04:31:28 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id f75so5177204wmf.2
        for <linux-mm@kvack.org>; Tue, 24 May 2016 04:31:27 -0700 (PDT)
Date: Tue, 24 May 2016 13:31:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Message-ID: <20160524113124.GF8259@dhcp22.suse.cz>
References: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
 <20160523174441.GA32715@dhcp22.suse.cz>
 <20160524084319.GH7917@esperanza>
 <20160524084737.GC8259@dhcp22.suse.cz>
 <20160524090142.GI7917@esperanza>
 <20160524092202.GD8259@dhcp22.suse.cz>
 <20160524100523.GJ7917@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160524100523.GJ7917@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 24-05-16 13:05:23, Vladimir Davydov wrote:
> On Tue, May 24, 2016 at 11:22:02AM +0200, Michal Hocko wrote:
[...]
> > you think about the following? I will cook up a full patch if this
> > (untested) looks ok.
> 
> It won't work for most filesystems as they define custom ->readpages. I
> wonder if it'd be OK to patch them all not to trigger oom.

readpages is mostly a wrapper for mpage_readpages so I guess this
wouldn't be a big deal.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
