Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6F46B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:36:20 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so1046401pdi.13
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:36:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qj3si3325508pbb.53.2014.06.18.13.36.19
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 13:36:20 -0700 (PDT)
Date: Wed, 18 Jun 2014 13:36:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 00/12] mm: memcontrol: naturalize charge lifetime v3
Message-Id: <20140618133618.663cdce4ee895ff52215065a@linux-foundation.org>
In-Reply-To: <20140618203124.GF7331@cmpxchg.org>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
	<20140617163615.GD9572@dhcp22.suse.cz>
	<20140618203124.GF7331@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 18 Jun 2014 16:31:24 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> I'm just going to resend the latest version with the acks you already
> provided, and then Andrew can decide whether he wants to take the last
> two as well right away, depending on testing and conflict resolution
> preferences and on how optimistic he is that you'll agree with them ;)

I can merge them and add a note-to-self regarding their status.  That
way we get a cycle of testing while Michal cogitates.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
