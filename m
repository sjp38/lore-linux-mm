Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id ECE976B0005
	for <linux-mm@kvack.org>; Sun, 27 May 2018 22:31:04 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y124-v6so9581494qkc.8
        for <linux-mm@kvack.org>; Sun, 27 May 2018 19:31:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u10-v6si3941940qkk.270.2018.05.27.19.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 May 2018 19:31:03 -0700 (PDT)
Date: Mon, 28 May 2018 10:30:43 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [RESEND PATCH V5 00/33] block: support multipage bvec
Message-ID: <20180528023042.GC26790@ming.t460p>
References: <20180525034621.31147-1-ming.lei@redhat.com>
 <20180525045306.GB8740@kmo-pixel>
 <8aa4276d-c0bc-3266-aa53-bf08a2e5ab5c@kernel.dk>
 <20180527072332.GA18240@ming.t460p>
 <cc266632-497c-6849-e291-4f042c8d987a@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cc266632-497c-6849-e291-4f042c8d987a@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Kent Overstreet <kent.overstreet@gmail.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On Sun, May 27, 2018 at 07:44:52PM -0600, Jens Axboe wrote:
> On 5/27/18 1:23 AM, Ming Lei wrote:
> > On Fri, May 25, 2018 at 10:30:46AM -0600, Jens Axboe wrote:
> >> On 5/24/18 10:53 PM, Kent Overstreet wrote:
> >>> On Fri, May 25, 2018 at 11:45:48AM +0800, Ming Lei wrote:
> >>>> Hi,
> >>>>
> >>>> This patchset brings multipage bvec into block layer:
> >>>
> >>> patch series looks sane to me. goddamn that's a lot of renaming.
> >>
> >> Indeed... I actually objected to some of the segment -> page
> >> renaming, but it's still in there. The foo2() temporary functions
> >> also concern me, we all know there's nothing more permanent than a
> >> temporary fixup.
> > 
> > Jens, I remember I explained the renaming story to you in lsfmm a bit:
> > 
> > 1) the current naming of segment is actually wrong, since every segment
> > only stores one single-page vector
> > 
> > 2) the most important part is that once multipage bvec is introduced,
> > if the old _segment naming is still kept, it can be very confusing,
> > especially no good name is left for the helpers of dealing with real
> > segment.
> 
> Yes, we discussed exactly this, which is why I'm surprised you went
> ahead with the same approach. I told you I don't like tree wide renames,

Maybe I misunderstood your point, that isn't strange given my poor
english, :-)

> if they can be avoided. I'd rather suffer some pain wrt page vs segments
> naming, and then later do a rename (if it bothers us) once the dust has
> settled on the interesting part of the changes.
> 
> I'm very well away of our current naming and what it signifies.  With
> #1, you are really splitting hairs, imho. Find a decent name for
> multiple segment. Chunk?

OK, will try _chunk in next post.

> 
> > For the foo2() temporary change, that is only for avoiding tree-wide
> > change in one single tree, with this way, we can change sub-system one
> > by one, but if you think it is good to do tree-wide conversion in one
> > patch, I am fine to do it in next version.
> 
> It's still a painful middle step.

I hate the conversion too, but looks it can't be avoided since
bio_for_each_segment_all() has to be changed.

Could you share us what your favorite approach is for this conversion?


Thanks,
Ming
