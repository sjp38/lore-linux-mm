Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCF06B0389
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 11:11:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r18so2374804wmd.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 08:11:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si2260828wrp.181.2017.02.22.08.11.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 08:11:29 -0800 (PST)
Date: Wed, 22 Feb 2017 17:11:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm,hugetlb: compute page_size_log properly
Message-ID: <20170222161128.ai4dyktyjog7kvw7@dhcp22.suse.cz>
References: <1486673582-6979-1-git-send-email-dave@stgolabs.net>
 <1486673582-6979-5-git-send-email-dave@stgolabs.net>
 <20170210102044.GA10054@dhcp22.suse.cz>
 <20170210165111.GB2392@linux-80c1.suse>
 <20170220161157.GO2431@dhcp22.suse.cz>
 <20170222160319.GB5126@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222160319.GB5126@linux-80c1.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, manfred@colorfullife.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

On Wed 22-02-17 08:03:19, Davidlohr Bueso wrote:
> On Mon, 20 Feb 2017, Michal Hocko wrote:
> 
> > I am not sure I understand.
> > $ git grep SHM_HUGE_ include/uapi/
> > $
> > 
> > So there doesn't seem to be any user visible constant. The man page
> > mentiones is but I do not really see how is the userspace supposed to
> > use it.
> 
> Yeah, userspace is not supposed to use it, it's just there because
> the manpage describes kernel internals.

Which is wrong!

> I'm not really a big fan
> of touching manpages (and ipc is already full of corner cases),
> but I guess nobody can really complain if we rip out all the
> SHM_HUGE_ stuff.

yeah, let's just get rid of it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
