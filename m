Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 15 Aug 2013 01:47:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/3] Pin page control subsystem
Message-ID: <20130814164705.GD2706@gmail.com>
References: <1376377502-28207-1-git-send-email-minchan@kernel.org>
 <00000140787b6191-ae3f2eb1-515e-48a1-8e64-502772af4700-000000@email.amazonses.com>
 <20130814001236.GC2271@bbox>
 <000001407dafbe92-7b2b4006-2225-4f0b-b23b-d66101a995aa-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001407dafbe92-7b2b4006-2225-4f0b-b23b-d66101a995aa-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, k.kozlowski@samsung.com, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Benjamin LaHaise <bcrl@kvack.org>, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>

Hi Christoph,

On Wed, Aug 14, 2013 at 04:36:44PM +0000, Christoph Lameter wrote:
> On Wed, 14 Aug 2013, Minchan Kim wrote:
> 
> > On Tue, Aug 13, 2013 at 04:21:30PM +0000, Christoph Lameter wrote:
> > > On Tue, 13 Aug 2013, Minchan Kim wrote:
> > >
> > > > VM sometime want to migrate and/or reclaim pages for CMA, memory-hotplug,
> > > > THP and so on but at the moment, it could handle only userspace pages
> > > > so if above example subsystem have pinned a some page in a range VM want
> > > > to migrate, migration is failed so above exmaple couldn't work well.
> > >
> > > Dont we have the mmu_notifiers that could help in that case? You could get
> > > a callback which could prepare the pages for migration?
> >
> > Now I'm not familiar with mmu_notifier so please could you elaborate it
> > a bit for me to dive into that?
> 
> Add a notifier callback for unpinning pages to the mmu notifier subsystem
> and then your drivers could register with the subsystem to get
> notifications when migration needs to occur etc.
> 

When I look API of mmu_notifier, it has mm_struct so I guess it works
for only user process. Right?
If so, I need to register it without user conext because zram, zswap
and zcache works for only kernel side.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
