Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id F139E6B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 11:14:40 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id mk6so6847906lab.15
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 08:14:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ir4si22542606lac.116.2014.10.13.08.14.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Oct 2014 08:14:37 -0700 (PDT)
Date: Mon, 13 Oct 2014 17:14:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/3] OOM vs. freezer interaction fixes
Message-ID: <20141013151435.GB15129@dhcp22.suse.cz>
References: <1412777266-8251-1-git-send-email-mhocko@suse.cz>
 <2107592.sy6uXko7kW@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2107592.sy6uXko7kW@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Thu 09-10-14 00:11:33, Rafael J. Wysocki wrote:
> On Wednesday, October 08, 2014 04:07:43 PM Michal Hocko wrote:
> > Hi Andrew, Rafael,
> > 
> > this has been originally discussed here [1] but didn't lead anywhere AFAICS
> > so I would like to resurrect them.
> 
> OK
> 
> So any chance to CC linux-pm too next time?  There are people on that list
> who may be interested as well and are not in the CC directly either.

Sure, sorry about that! I've simply used the same CC list as the
previous post without realizing PM list was missing.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
