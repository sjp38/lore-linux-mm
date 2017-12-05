Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC696B026B
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 03:58:41 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b82so5362708wmd.5
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 00:58:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d58si1568844ede.268.2017.12.05.00.58.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 00:58:40 -0800 (PST)
Date: Tue, 5 Dec 2017 09:58:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/4] lockdep/crossrelease: Apply crossrelease to page
 locks
Message-ID: <20171205085837.7oo6j5bp6y3xqope@dhcp22.suse.cz>
References: <1512364583-26070-1-git-send-email-byungchul.park@lge.com>
 <20171205053023.GB20757@bombadil.infradead.org>
 <0aad02e4-f477-1ee3-471a-3e1371ebba1e@lge.com>
 <55674f0a-7886-f1d2-d7f1-6bf42c1e89e3@lge.com>
 <20171205074517.GA11477@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171205074517.GA11477@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

On Mon 04-12-17 23:45:17, Matthew Wilcox wrote:
> On Tue, Dec 05, 2017 at 03:19:46PM +0900, Byungchul Park wrote:
> > On 12/5/2017 2:46 PM, Byungchul Park wrote:
> > > On 12/5/2017 2:30 PM, Matthew Wilcox wrote:
> > > > On Mon, Dec 04, 2017 at 02:16:19PM +0900, Byungchul Park wrote:
> > > > > For now, wait_for_completion() / complete() works with lockdep, add
> > > > > lock_page() / unlock_page() and its family to lockdep support.
> > > > > 
> > > > > Changes from v1
> > > > >   - Move lockdep_map_cross outside of page_ext to make it flexible
> > > > >   - Prevent allocating lockdep_map per page by default
> > > > >   - Add a boot parameter allowing the allocation for debugging
> > > > > 
> > > > > Byungchul Park (4):
> > > > >    lockdep: Apply crossrelease to PG_locked locks
> > > > >    lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
> > > > >    lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext
> > > > >    lockdep: Add a boot parameter enabling to track page locks using
> > > > >      lockdep and disable it by default
> > > > 
> > > > I don't like the way you've structured this patch series; first adding
> > > > the lockdep map to struct page, then moving it to page_ext.
> > > 
> > > Hello,
> > > 
> > > I will make them into one patch.
> > 
> > I've thought it more.
> > 
> > Actually I did it because I thought I'd better make it into two
> > patches since it makes reviewers easier to review. It doesn't matter
> > which one I choose, but I prefer to split it.
> 
> I don't know whether it's better to make it all one patch or split it
> into multiple patches.  But it makes no sense to introduce it in struct
> page, then move it to struct page_ext.

I would tend to agree. It is not like anybody would like to apply only
the first part alone. Adding the necessary infrastructure to page_ext is
not such a big deal.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
