Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id E61976B006E
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 14:00:28 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so2921858wiw.7
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 11:00:28 -0800 (PST)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id e7si6633358wib.100.2014.12.07.11.00.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 11:00:28 -0800 (PST)
Received: by mail-wg0-f50.google.com with SMTP id k14so4684583wgh.9
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 11:00:28 -0800 (PST)
Date: Sun, 7 Dec 2014 20:00:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/4] OOM vs PM freezer fixes
Message-ID: <20141207190026.GB29065@dhcp22.suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <20141207100953.GC15892@dhcp22.suse.cz>
 <20141207135551.GA19034@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141207135551.GA19034@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Sun 07-12-14 08:55:51, Tejun Heo wrote:
> On Sun, Dec 07, 2014 at 11:09:53AM +0100, Michal Hocko wrote:
> > this is another attempt to address OOM vs. PM interaction. More
> > about the issue is described in the last patch. The other 4 patches
> > are just clean ups. This is based on top of 3.18-rc3 + Johannes'
> > http://marc.info/?l=linux-kernel&m=141779091114777 which is not in the
> > Andrew's tree yet but I wanted to prevent from later merge conflicts.
> 
> When the patches are based on a custom tree, it's often a good idea to
> create a git branch of the patches to help reviewing.

git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git to-review/make-oom-vs-pm-freezing-more-robust-2
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
