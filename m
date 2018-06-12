Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7C56B0269
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 23:43:10 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x186-v6so21191384qkb.0
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 20:43:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t63-v6si7853524qkc.196.2018.06.11.20.43.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 20:43:09 -0700 (PDT)
Date: Tue, 12 Jun 2018 11:42:49 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V6 00/30] block: support multipage bvec
Message-ID: <20180612034242.GC26412@ming.t460p>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180611164806.GA7452@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180611164806.GA7452@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Mon, Jun 11, 2018 at 09:48:06AM -0700, Christoph Hellwig wrote:
> D? think the new naming scheme in this series is a nightmare.  It
> confuses the heck out of me, and that is despite knowing many bits of
> the block layer inside out, and reviewing previous series.

In V5, there isn't such issue, since bio_for_each_segment* is renamed
into bio_for_each_page* first before doing the change.

> 
> I think we need to take a step back and figure out what names what we
> want in the end, and how we get there separately.

Right, I agree, last year I told people that naming may be the biggest
issue for this patchset.

> 
> For the end result using bio_for_each_page in some form for the per-page
> iteration seems like the only sensible idea, as that is what it does.

Yeah, I agree, but except for renaming bio_for_each_segment* into
bio_for_each_page* or whatever first, I don't see any way to deal with
it cleanly.

Seems Jens isn't fine with the big renaming, then I follow the suggestion
of taking 'chunk' for representing multipage bvec in V6.

> 
> For the bio-vec iteration I'm fine with either bio_for_each_bvec as that
> exactly explains what it does, or bio_for_each_segment to keep the
> change at a minimum.

If bio_for_each_segment() is fine, that is basically what this patch is doing,
then could you share me what the actual naming issue is in V6? And
basically the name of 'chunk' is introduced for multipage bvec.

> 
> And in terms of how to get there: maybe we need to move all the drivers
> and file systems to the new names first before the actual changes to
> document all the intent.

That is exactly what I have done in V5, but that way is refused.

Guys, so what can we do to make progress for this naming issue? 


Thanks,
Ming
