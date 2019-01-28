From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Date: Mon, 28 Jan 2019 08:12:01 -0800
Message-ID: <20190128161201.GS50184@devbig004.ftw2.facebook.com>
References: <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <CALvZod6LFY+FYfBcAX0kLxV5KKB1-TX2cU5EDyyyjvHOtuWWbA@mail.gmail.com>
 <20190128160512.GR50184@devbig004.ftw2.facebook.com>
 <CALvZod5Rrr6ENW5yLNzniFeFmGB=mDRH+guNLmcayTX-_xDAGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALvZod5Rrr6ENW5yLNzniFeFmGB=mDRH+guNLmcayTX-_xDAGw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, kernel-team@fb.com
List-Id: linux-mm.kvack.org

Hello,

On Mon, Jan 28, 2019 at 08:08:26AM -0800, Shakeel Butt wrote:
> Do you envision a separate interface/file for recursive and local
> counters? That would make notifications simpler but that is an
> additional interface.

I need to think more about it but my first throught is that a separate
file would make more sense given that separating notifications could
be useful.

Thanks.

-- 
tejun
