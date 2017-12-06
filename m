Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 262DC6B035C
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 03:07:59 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c9so1639968wrb.4
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 00:07:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k18si2003532edf.226.2017.12.06.00.07.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 00:07:57 -0800 (PST)
Date: Wed, 6 Dec 2017 09:07:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
Message-ID: <20171206080756.GB16386@dhcp22.suse.cz>
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
 <20171205144948.ezgo3xpjeytkq6ua@dhcp22.suse.cz>
 <20171205155618.7a3a59751ed49c704210b736@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205155618.7a3a59751ed49c704210b736@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <longman@redhat.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 05-12-17 15:56:18, Andrew Morton wrote:
> On Tue, 5 Dec 2017 15:49:48 +0100 Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > It also seems that there is no general agreement in the patch. Andrew,
> > do you plan to keep it?
> 
> It's in wait-and-see mode.

OK, I will remove m32r from my compile test battery.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
