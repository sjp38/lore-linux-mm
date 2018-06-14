Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4646B000C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 21:21:16 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 12-v6so3367240qtq.8
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 18:21:16 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s29-v6si2923732qki.146.2018.06.13.18.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 18:21:15 -0700 (PDT)
Date: Thu, 14 Jun 2018 09:20:53 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V6 00/30] block: support multipage bvec
Message-ID: <20180614012052.GB19828@ming.t460p>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180613145908.GB17340@kmo-pixel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180613145908.GB17340@kmo-pixel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Wed, Jun 13, 2018 at 10:59:08AM -0400, Kent Overstreet wrote:
> On Sat, Jun 09, 2018 at 08:29:44PM +0800, Ming Lei wrote:
> > Hi,
> > 
> > This patchset brings multipage bvec into block layer:
> 
> Ming, what's going on with the chunk naming? I haven't been paying attention
> because it feels like it's turned into bike shedding, but I just saw something
> about a 3rd way of iterating over bios? (page/segment/chunk...?)

This patchset takes the chunk naming.

And 'chunk' represents multipage bvec, and 'segment' represents singlepage bvec
basically.

Thanks,
Ming
