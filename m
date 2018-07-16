Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 127B06B0007
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 05:10:44 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b9-v6so3506793pgq.17
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 02:10:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o1-v6si6542254pge.572.2018.07.16.02.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 02:10:42 -0700 (PDT)
Date: Mon, 16 Jul 2018 11:10:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180716091040.GH17280@dhcp22.suse.cz>
References: <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
 <1531336913.3260.18.camel@HansenPartnership.com>
 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
 <1531411494.18255.6.camel@HansenPartnership.com>
 <20180712164932.GA3475@bombadil.infradead.org>
 <1531416080.18255.8.camel@HansenPartnership.com>
 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
 <1531425435.18255.17.camel@HansenPartnership.com>
 <20180713003614.GW2234@dastard>
 <1531496812.3361.9.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1531496812.3361.9.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On Fri 13-07-18 08:46:52, James Bottomley wrote:
> On Fri, 2018-07-13 at 10:36 +1000, Dave Chinner wrote:
> > On Thu, Jul 12, 2018 at 12:57:15PM -0700, James Bottomley wrote:
> > > What surprises me most about this behaviour is the steadiness of
> > > the page cache ... I would have thought we'd have shrunk it
> > > somewhat given the intense call on the dcache.
> > 
> > Oh, good, the page cache vs superblock shrinker balancing still
> > protects the working set of each cache the way it's supposed to
> > under heavy single cache pressure. :)
> 
> Well, yes, but my expectation is most of the page cache is clean, so
> easily reclaimable.  I suppose part of my surprise is that I expected
> us to reclaim the clean caches first before we started pushing out the
> dirty stuff and reclaiming it.  I'm not saying it's a bad thing, just
> saying I didn't expect us to make such good decisions under the
> parameters of this test.

This is indeed unepxected. Especially when the current LRU reclaim balancing
logic is highly pagecache biased. Are you sure you were not running in a
memcg with a small amount of the pagecache?
-- 
Michal Hocko
SUSE Labs
