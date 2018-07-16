Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E09296B000A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 05:12:26 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id e93-v6so22285146plb.5
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 02:12:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u14-v6si26794525pgv.180.2018.07.16.02.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 02:12:26 -0700 (PDT)
Date: Mon, 16 Jul 2018 11:12:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180716091222.GI17280@dhcp22.suse.cz>
References: <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
 <1531336913.3260.18.camel@HansenPartnership.com>
 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
 <1531411494.18255.6.camel@HansenPartnership.com>
 <20180712164932.GA3475@bombadil.infradead.org>
 <1531416080.18255.8.camel@HansenPartnership.com>
 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
 <1531425435.18255.17.camel@HansenPartnership.com>
 <20180713003614.GW2234@dastard>
 <20180716090901.GG17280@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716090901.GG17280@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On Mon 16-07-18 11:09:01, Michal Hocko wrote:
> On Fri 13-07-18 10:36:14, Dave Chinner wrote:
> [...]
> > By limiting the number of negative dentries in this case, internal
> > slab fragmentation is reduced such that reclaim cost never gets out
> > of control. While it appears to "fix" the symptoms, it doesn't
> > address the underlying problem. It is a partial solution at best but
> > at worst it's another opaque knob that nobody knows how or when to
> > tune.
> 
> Would it help to put all the negative dentries into its own slab cache?

We couldn't http://lkml.kernel.org/r/20180714173516.uumlhs4wgfgrlc32@devuan
Sorry I haven't noticed the other line of discussion
-- 
Michal Hocko
SUSE Labs
