Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCD16B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 05:06:59 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k135so92455589lfb.2
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 02:06:59 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id di2si2149663wjc.106.2016.08.23.02.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 02:06:57 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so17171808wme.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 02:06:57 -0700 (PDT)
Date: Tue, 23 Aug 2016 11:06:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160823090655.GA23583@dhcp22.suse.cz>
References: <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
 <20160822130311.GL13596@dhcp22.suse.cz>
 <20160822210123.5k6zwdrkhrwjw5vv@redhat.com>
 <20160823075555.GE23577@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823075555.GE23577@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Tue 23-08-16 09:55:55, Michal Hocko wrote:
> On Tue 23-08-16 00:01:23, Michael S. Tsirkin wrote:
> [...]
> > Actually, vhost net calls out to tun which does regular copy_from_iter.
> > Returning 0 there will cause corrupted packets in the network: not a
> > huge deal, but ugly.  And I don't think we want to annotate run and
> > macvtap as well.
> 
> Hmm, OK, I wasn't aware of that path and being consistent here matters.
> If the vhost driver can interact with other subsystems then there is
> really no other option than hooking into the page fault path. Ohh well.

Here is a completely untested patch just for sanity check.
---
