Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 598FE6B0005
	for <linux-mm@kvack.org>; Fri, 25 May 2018 12:30:52 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g5-v6so4788008ioc.4
        for <linux-mm@kvack.org>; Fri, 25 May 2018 09:30:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j126-v6sor12799548ioe.274.2018.05.25.09.30.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 May 2018 09:30:50 -0700 (PDT)
Subject: Re: [RESEND PATCH V5 00/33] block: support multipage bvec
References: <20180525034621.31147-1-ming.lei@redhat.com>
 <20180525045306.GB8740@kmo-pixel>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <8aa4276d-c0bc-3266-aa53-bf08a2e5ab5c@kernel.dk>
Date: Fri, 25 May 2018 10:30:46 -0600
MIME-Version: 1.0
In-Reply-To: <20180525045306.GB8740@kmo-pixel>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>, Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On 5/24/18 10:53 PM, Kent Overstreet wrote:
> On Fri, May 25, 2018 at 11:45:48AM +0800, Ming Lei wrote:
>> Hi,
>>
>> This patchset brings multipage bvec into block layer:
> 
> patch series looks sane to me. goddamn that's a lot of renaming.

Indeed... I actually objected to some of the segment -> page renaming,
but it's still in there. The foo2() temporary functions also concern me,
we all know there's nothing more permanent than a temporary fixup.

> Things are going to get interesting when we start sticking compound pages in the
> page cache, there'll be some interesting questions of semantics to deal with
> then but I think getting this will only help w.r.t. plumbing that through and
> not dealing with 4k pages unnecessarily - but I think even if we were to decide
> that merging in bio_add_page() is not the way to go when the upper layers are
> passing compound pages around already, this patch series helps because
> regardless at some point everything under generic_make_request() is going to
> have to deal with segments that are more than one page, and this patch series
> makes that happen. So incremental progress.
> 
> Jens, any objections to getting this in?

I like most of it, but I'd much rather get this way earlier in the series.
We're basically just one week away from the merge window, it needs more simmer
and testing time than that. On top of that, it hasn't received much review
yet.

So as far as I'm concerned, we can kick off the 4.19 block branch with
iterated versions of this patchset.

-- 
Jens Axboe
