Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A1B9682F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 12:10:28 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so47736091wic.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 09:10:28 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j64si12253819wmd.123.2015.10.29.09.10.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 09:10:27 -0700 (PDT)
Date: Thu, 29 Oct 2015 09:10:09 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151029161009.GA9160@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
 <20151023131956.GA15375@dhcp22.suse.cz>
 <20151023.065957.1690815054807881760.davem@davemloft.net>
 <20151026165619.GB2214@cmpxchg.org>
 <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151029152546.GG23598@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 29, 2015 at 04:25:46PM +0100, Michal Hocko wrote:
> On Tue 27-10-15 09:42:27, Johannes Weiner wrote:
> > On Tue, Oct 27, 2015 at 05:15:54PM +0100, Michal Hocko wrote:
> > > On Tue 27-10-15 11:41:38, Johannes Weiner wrote:
> > > > IMO that's an implementation detail and a historical artifact that
> > > > should not be exposed to the user. And that's the thing I hate about
> > > > the current opt-out knob.
> > 
> > You carefully skipped over this part. We can ignore it for socket
> > memory but it's something we need to figure out when it comes to slab
> > accounting and tracking.
> 
> I am sorry, I didn't mean to skip this part, I though it would be clear
> from the previous text. I think kmem accounting falls into the same
> category. Have a sane default and a global boottime knob to override it
> for those that think differently - for whatever reason they might have.

Yes, that makes sense to me.

Like cgroup.memory=nosocket, would you think it makes sense to include
slab in the default for functional/semantical completeness and provide
a cgroup.memory=noslab for powerusers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
