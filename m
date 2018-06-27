Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE7F6B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 03:22:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f6-v6so1052614eds.6
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 00:22:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w44-v6si1641395edb.165.2018.06.27.00.22.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 00:22:09 -0700 (PDT)
Date: Wed, 27 Jun 2018 09:22:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Message-ID: <20180627072207.GB32348@dhcp22.suse.cz>
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
 <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
 <20180626170345.GA3593@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180626170345.GA3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue 26-06-18 10:03:45, Paul E. McKenney wrote:
[...]
> 3.	Something else?

How hard it would be to use a different API than oom notifiers? E.g. a
shrinker which just kicks all the pending callbacks if the reclaim
priority reaches low values (e.g. 0)?
-- 
Michal Hocko
SUSE Labs
