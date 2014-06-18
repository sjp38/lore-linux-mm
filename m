Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4CDDD6B0039
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 17:02:26 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id b13so1390955wgh.11
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 14:02:25 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id s8si4201841wif.65.2014.06.18.14.02.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 14:02:24 -0700 (PDT)
Received: by mail-wi0-f176.google.com with SMTP id n3so8334879wiv.9
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 14:02:24 -0700 (PDT)
Date: Wed, 18 Jun 2014 23:02:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 00/12] mm: memcontrol: naturalize charge lifetime v3
Message-ID: <20140618210222.GA2397@dhcp22.suse.cz>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
 <20140617163615.GD9572@dhcp22.suse.cz>
 <20140618203124.GF7331@cmpxchg.org>
 <20140618133618.663cdce4ee895ff52215065a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140618133618.663cdce4ee895ff52215065a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 18-06-14 13:36:18, Andrew Morton wrote:
> On Wed, 18 Jun 2014 16:31:24 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > I'm just going to resend the latest version with the acks you already
> > provided, and then Andrew can decide whether he wants to take the last
> > two as well right away, depending on testing and conflict resolution
> > preferences and on how optimistic he is that you'll agree with them ;)
> 
> I can merge them and add a note-to-self regarding their status.  That
> way we get a cycle of testing while Michal cogitates.

Sure, that makes sense.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
