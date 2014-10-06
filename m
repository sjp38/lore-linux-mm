Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EC6666B0069
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 02:38:44 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kx10so4870027pab.9
        for <linux-mm@kvack.org>; Sun, 05 Oct 2014 23:38:44 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rb7si12591909pab.142.2014.10.05.23.38.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Oct 2014 23:38:43 -0700 (PDT)
Date: Mon, 6 Oct 2014 10:38:29 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20141006063829.GB1162@esperanza>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
 <20140926103104.GE29445@esperanza>
 <20141002120748.GA1359@cmpxchg.org>
 <20141003153623.GA1162@esperanza>
 <20141003154134.GG4816@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141003154134.GG4816@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Oct 03, 2014 at 05:41:34PM +0200, Michal Hocko wrote:
> On Fri 03-10-14 19:36:23, Vladimir Davydov wrote:
> > On Thu, Oct 02, 2014 at 08:07:48AM -0400, Johannes Weiner wrote:
> [...]
> > > The barriers are implied in change-return atomics, which is why there
> > > is an xchg.  But it's clear that this needs to be documented.  This?:
> > 
> > With the comments it looks correct to me, but I wonder if we can always
> > rely on implicit memory barriers issued by atomic ops. Are there any
> > archs where it doesn't hold?
> 
> xchg is explcitly mentioned in Documentation/memory-barriers.txt so it
> is expected to be barrier on all archs. Besides that not all atomic ops
> imply memory barriers. Only those that "modifies some state in memory
> and returns information about the state" do.

Thank you for the info, now it's clear to me.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
