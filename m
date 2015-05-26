Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C54C56B0158
	for <linux-mm@kvack.org>; Tue, 26 May 2015 07:50:21 -0400 (EDT)
Received: by wghq2 with SMTP id q2so94678160wgh.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 04:50:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gw2si17695298wib.96.2015.05.26.04.50.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 May 2015 04:50:20 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 0/3] get rid of mm_struct::owner
Date: Tue, 26 May 2015 13:50:03 +0200
Message-Id: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
this small series drops IMO awkward mm_struct::owner field which is
used to track task which owns the mm_struct and which is then used for
mm->mem_cgroup mapping. The motivation for the change and drawback
(namely user visible change of behavior) is described in the patch 3.

The first patch is a trivial cleanup by Tejun
(http://marc.info/?l=linux-mm&m=143197860820270) and I have added it
here just to prevent from conflicts with his changes.

Patch 2 is preparatory and it shouldn't cause any functional changes.
It simply replaces mc.to as an indicator of the charge migration
during task move by using mc.moving_task because we need to have mc.to
available even when the charges are not migrated.

I am sending this as an RFC because of the user visible aspect of the
change. I am not convinced that there is a strong usecase to justify
keeping mm->owner but I would like to hear back first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
