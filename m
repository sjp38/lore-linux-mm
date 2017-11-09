Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64F6E440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 08:54:47 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 107so3184195wra.7
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 05:54:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b18si5468140edh.47.2017.11.09.05.54.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 05:54:46 -0800 (PST)
Date: Thu, 9 Nov 2017 14:54:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Message-ID: <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
References: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
 <20171030124358.GF23278@quack2.suse.cz>
 <76a4d544-833a-5f42-a898-115640b6783b@alibaba-inc.com>
 <20171031101238.GD8989@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031101238.GD8989@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Yang Shi <yang.s@alibaba-inc.com>, amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

[Sorry for the late reply]

On Tue 31-10-17 11:12:38, Jan Kara wrote:
> On Tue 31-10-17 00:39:58, Yang Shi wrote:
[...]
> > I do agree it is not fair and not neat to account to producer rather than
> > misbehaving consumer, but current memcg design looks not support such use
> > case. And, the other question is do we know who is the listener if it
> > doesn't read the events?
> 
> So you never know who will read from the notification file descriptor but
> you can simply account that to the process that created the notification
> group and that is IMO the right process to account to.

Yes, if the creator is de-facto owner which defines the lifetime of
those objects then this should be a target of the charge.

> I agree that current SLAB memcg accounting does not allow to account to a
> different memcg than the one of the running process. However I *think* it
> should be possible to add such interface. Michal?

We do have memcg_kmem_charge_memcg but that would require some plumbing
to hook it into the specific allocation path. I suspect it uses kmalloc,
right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
