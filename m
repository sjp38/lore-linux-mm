Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id EB6C16B0069
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 11:41:35 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id fb4so2522072wid.10
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 08:41:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q20si2477250wie.36.2014.10.03.08.41.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Oct 2014 08:41:35 -0700 (PDT)
Date: Fri, 3 Oct 2014 17:41:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20141003154134.GG4816@dhcp22.suse.cz>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
 <20140926103104.GE29445@esperanza>
 <20141002120748.GA1359@cmpxchg.org>
 <20141003153623.GA1162@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141003153623.GA1162@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 03-10-14 19:36:23, Vladimir Davydov wrote:
> On Thu, Oct 02, 2014 at 08:07:48AM -0400, Johannes Weiner wrote:
[...]
> > The barriers are implied in change-return atomics, which is why there
> > is an xchg.  But it's clear that this needs to be documented.  This?:
> 
> With the comments it looks correct to me, but I wonder if we can always
> rely on implicit memory barriers issued by atomic ops. Are there any
> archs where it doesn't hold?

xchg is explcitly mentioned in Documentation/memory-barriers.txt so it
is expected to be barrier on all archs. Besides that not all atomic ops
imply memory barriers. Only those that "modifies some state in memory
and returns information about the state" do.
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
