Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32574C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 08:10:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3847206C2
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 08:10:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3847206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90A256B0005; Fri, 16 Aug 2019 04:10:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BAB36B0006; Fri, 16 Aug 2019 04:10:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D0616B0007; Fri, 16 Aug 2019 04:10:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0194.hostedemail.com [216.40.44.194])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA0A6B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 04:10:34 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B7DC6181AC9AE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:10:33 +0000 (UTC)
X-FDA: 75827569146.29.coat37_4d895dfe694f
X-HE-Tag: coat37_4d895dfe694f
X-Filterd-Recvd-Size: 4590
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:10:33 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 41A16AD20;
	Fri, 16 Aug 2019 08:10:31 +0000 (UTC)
Date: Fri, 16 Aug 2019 10:10:29 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190816081029.GA27790@dhcp22.suse.cz>
References: <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz>
 <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz>
 <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz>
 <20190815201323.GU21596@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815201323.GU21596@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 17:13:23, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 09:35:26PM +0200, Michal Hocko wrote:
> 
> > > The last detail is I'm still unclear what a GFP flags a blockable
> > > invalidate_range_start() should use. Is GFP_KERNEL OK?
> > 
> > I hope I will not make this muddy again ;)
> > invalidate_range_start in the blockable mode can use/depend on any sleepable
> > allocation allowed in the context it is called from. 
> 
> 'in the context is is called from' is the magic phrase, as
> invalidate_range_start is called while holding several different mm
> related locks. I know at least write mmap_sem and i_mmap_rwsem
> (write?)
> 
> Can GFP_KERNEL be called while holding those locks?

i_mmap_rwsem would be problematic because it is taken during the
reclaim.

> This is the question of indirect dependency on reclaim via locks you
> raised earlier.
> 
> > So in other words it is no different from any other function in the
> > kernel that calls into allocator. As the API is missing gfp context
> > then I hope it is not called from any restricted contexts (except
> > from the oom which we have !blockable for).
> 
> Yes, the callers are exactly my concern.
>  
> > > Lockdep has
> > > complained on that in past due to fs_reclaim - how do you know if it
> > > is a false positive?
> > 
> > I would have to see the specific lockdep splat.
> 
> See below. I found it when trying to understand why the registration
> of the mmu notififer was so oddly coded.
> 
> The situation was:
> 
>   down_write(&mm->mmap_sem);
>   mm_take_all_locks(mm);
>   kmalloc(GFP_KERNEL);  <--- lockdep warning

Ugh. mm_take_all_locks :/

> I understood Daniel said he saw this directly on a recent kernel when
> working with his lockdep patch?
> 
> Checking myself, on todays kernel I see a call chain:
> 
> shrink_all_memory
>   fs_reclaim_acquire(sc.gfp_mask);
>   [..]
>   do_try_to_free_pages
>    shrink_zones
>     shrink_node
>      shrink_node_memcg
>       shrink_list
>        shrink_active_list
>         page_referenced
>          rmap_walk
>           rmap_walk_file
>            i_mmap_lock_read
>             down_read(i_mmap_rwsem)
> 
> So it is possible that the down_read() above will block on
> i_mmap_rwsem being held in the caller of invalidate_range_start which
> is doing kmalloc(GPF_KERNEL).
> 
> Is this OK? The lockdep annotation says no..

It's not as per the above code patch which is easily possible because
mm_take_all_locks will lock all file vmas.

-- 
Michal Hocko
SUSE Labs

