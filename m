Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 831066B0006
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 04:54:50 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d7-v6so423645pfj.6
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 01:54:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1-v6si693772pgk.593.2018.10.23.01.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 01:54:49 -0700 (PDT)
Date: Tue, 23 Oct 2018 10:54:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181023085445.GQ18839@dhcp22.suse.cz>
References: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018042739.GA650@jagdpanzerIV>
 <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
 <20181018061018.GB650@jagdpanzerIV>
 <20181018075611.GY18839@dhcp22.suse.cz>
 <20181018081352.GA438@jagdpanzerIV>
 <2c2b2820-e6f8-76c8-c431-18f60845b3ab@i-love.sakura.ne.jp>
 <20181018235427.GA877@jagdpanzerIV>
 <5d472476-7852-f97b-9412-63536dffaa0e@i-love.sakura.ne.jp>
 <20181023083738.o4wo3jxw3xkp3rwx@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023083738.o4wo3jxw3xkp3rwx@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

[I strongly suspect this whole email thread went way out of scope of the
 issue really deserves]

I didn't want to participate any further but let me clarify one thing
because I can see how the discussion could generate some confusion.

On Tue 23-10-18 10:37:38, Petr Mladek wrote:
[...]
> My understanding is that this situation happens when the system is
> misconfigured and unusable without manual intervention. If
> the user is able to see what the problem is then we are good.

Not really. The flood of _memcg_ oom report about no eligible tasks
should indeed happen only when the memcg is misconfigured. The system is
and should be still usable at this stage. Ratelimit is aimed to reduce
pointless message which do not help to debug the issue itself much.
There is a race condition as explained by Tetsuo that could lead to this
situation even without a misconfiguration and that is clearly a bug and
something to deal with and patches have been posted in that regards [1]

The rest of the discussion is about how to handle printk rate-limiting
properly and whether ad-hoc solution is more appropriate than a real API
we have in place and whether the later needs some enhancements. That is
completely orthogonal on the issue at hands and as such it should be
really discussed separately.

[1] http://lkml.kernel.org/r/20181022071323.9550-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs
