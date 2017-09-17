Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B75146B0038
	for <linux-mm@kvack.org>; Sun, 17 Sep 2017 13:45:42 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q7so13405326ioi.3
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 10:45:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u134si3360612oif.186.2017.09.17.10.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 10:45:41 -0700 (PDT)
Date: Sun, 17 Sep 2017 10:45:34 -0700
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/memcg: avoid page count check for zone device
Message-ID: <20170917174534.GC11906@redhat.com>
References: <20170914190011.5217-1-jglisse@redhat.com>
 <20170915070100.2vuxxxk2zf2yceca@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170915070100.2vuxxxk2zf2yceca@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Fri, Sep 15, 2017 at 09:01:00AM +0200, Michal Hocko wrote:
> On Thu 14-09-17 15:00:11, jglisse@redhat.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > Fix for 4.14, zone device page always have an elevated refcount
> > of one and thus page count sanity check in uncharge_page() is
> > inappropriate for them.
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Reported-by: Evgeny Baskakov <ebaskakov@nvidia.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Side note. Wouldn't it be better to re-organize the check a bit? It is
> true that this is VM_BUG so it is not usually compiled in but when it
> preferably checks for unlikely cases first while the ref count will be
> 0 in the prevailing cases. So can we have
> 	VM_BUG_ON_PAGE(page_count(page) && !is_zone_device_page(page) &&
> 			!PageHWPoison(page), page);
> 
> I would simply fold this nano optimization into the patch as you are
> touching it already. Not sure it is worth a separate commit.

I am traveling sorry for late answer. This nano optimization make sense
Andrew do you want me to respin or should we leave it be ? I don't mind
either way.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
