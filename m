Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4388E6B0007
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 10:59:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id h4-v6so2263926qkm.9
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 07:59:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b14-v6sor1434776qvj.144.2018.06.13.07.59.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Jun 2018 07:59:12 -0700 (PDT)
Date: Wed, 13 Jun 2018 10:59:08 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH V6 00/30] block: support multipage bvec
Message-ID: <20180613145908.GB17340@kmo-pixel>
References: <20180609123014.8861-1-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Sat, Jun 09, 2018 at 08:29:44PM +0800, Ming Lei wrote:
> Hi,
> 
> This patchset brings multipage bvec into block layer:

Ming, what's going on with the chunk naming? I haven't been paying attention
because it feels like it's turned into bike shedding, but I just saw something
about a 3rd way of iterating over bios? (page/segment/chunk...?)
