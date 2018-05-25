Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6052E6B02D3
	for <linux-mm@kvack.org>; Fri, 25 May 2018 00:53:11 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c73-v6so3115642qke.2
        for <linux-mm@kvack.org>; Thu, 24 May 2018 21:53:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p187-v6sor13511495qkb.125.2018.05.24.21.53.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 21:53:10 -0700 (PDT)
Date: Fri, 25 May 2018 00:53:06 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [RESEND PATCH V5 00/33] block: support multipage bvec
Message-ID: <20180525045306.GB8740@kmo-pixel>
References: <20180525034621.31147-1-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@fb.com>
Cc: Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On Fri, May 25, 2018 at 11:45:48AM +0800, Ming Lei wrote:
> Hi,
> 
> This patchset brings multipage bvec into block layer:

patch series looks sane to me. goddamn that's a lot of renaming.

Things are going to get interesting when we start sticking compound pages in the
page cache, there'll be some interesting questions of semantics to deal with
then but I think getting this will only help w.r.t. plumbing that through and
not dealing with 4k pages unnecessarily - but I think even if we were to decide
that merging in bio_add_page() is not the way to go when the upper layers are
passing compound pages around already, this patch series helps because
regardless at some point everything under generic_make_request() is going to
have to deal with segments that are more than one page, and this patch series
makes that happen. So incremental progress.

Jens, any objections to getting this in?
