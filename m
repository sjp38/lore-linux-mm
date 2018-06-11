Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 084B66B000C
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 12:48:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j10-v6so6744387pgv.6
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 09:48:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y65-v6si25609129pfi.195.2018.06.11.09.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 09:48:20 -0700 (PDT)
Date: Mon, 11 Jun 2018 09:48:06 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V6 00/30] block: support multipage bvec
Message-ID: <20180611164806.GA7452@infradead.org>
References: <20180609123014.8861-1-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

D? think the new naming scheme in this series is a nightmare.  It
confuses the heck out of me, and that is despite knowing many bits of
the block layer inside out, and reviewing previous series.

I think we need to take a step back and figure out what names what we
want in the end, and how we get there separately.

For the end result using bio_for_each_page in some form for the per-page
iteration seems like the only sensible idea, as that is what it does.

For the bio-vec iteration I'm fine with either bio_for_each_bvec as that
exactly explains what it does, or bio_for_each_segment to keep the
change at a minimum.

And in terms of how to get there: maybe we need to move all the drivers
and file systems to the new names first before the actual changes to
document all the intent.  For that using the bio_for_each_bvec variant
might be benefitial as it allows to seasily see the difference between
old uncovered code and the already converted one.
