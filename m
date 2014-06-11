Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id B9A916B015A
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 08:31:12 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id i13so4561743qae.33
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 05:31:12 -0700 (PDT)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id q20si31209676qac.109.2014.06.11.05.31.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 05:31:12 -0700 (PDT)
Received: by mail-qa0-f44.google.com with SMTP id j7so11096490qaq.3
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 05:31:12 -0700 (PDT)
Date: Wed, 11 Jun 2014 08:31:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: Allow hard guarantee mode for low limit
 reclaim
Message-ID: <20140611123109.GA17777@htj.dyndns.org>
References: <20140606144421.GE26253@dhcp22.suse.cz>
 <1402066010-25901-1-git-send-email-mhocko@suse.cz>
 <1402066010-25901-2-git-send-email-mhocko@suse.cz>
 <xr934mzt4rwc.fsf@gthelen.mtv.corp.google.com>
 <20140610165756.GG2878@cmpxchg.org>
 <20140611075729.GA4520@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140611075729.GA4520@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hello, Michal.

On Wed, Jun 11, 2014 at 09:57:29AM +0200, Michal Hocko wrote:
> Is this the kind of symmetry Tejun is asking for and that would make
> change is Nack position? I am still not sure it satisfies his soft

Yes, pretty much.  What primarily bothered me was the soft/hard
guarantees being chosen by a toggle switch while the soft/hard limits
can be configured separately and combined.

> guarantee objections from other email.

I was wondering about the usefulness of "low" itself in isolation and
I still think it'd be less useful than "high", but as there seem to be
use cases which can be served with that and especially as a part of a
consistent control scheme, I have no objection.

"low" definitely requires a notification mechanism tho.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
