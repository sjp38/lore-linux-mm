Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC9F6B0007
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 06:22:06 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id q18-v6so10448957wrr.12
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 03:22:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v111-v6si9213704wrc.244.2018.08.06.03.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 03:22:04 -0700 (PDT)
Date: Mon, 6 Aug 2018 12:22:03 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: adjust max read count in generic_file_buffered_read()
Message-ID: <20180806102203.hmobd26cujmlfcsw@quack2.suse.cz>
References: <20180719081726.3341-1-cgxu519@gmx.com>
 <20180719085812.sjup2odrjyuigt3l@quack2.suse.cz>
 <20180720161429.d63dccb9f66799dc0ff74dba@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180720161429.d63dccb9f66799dc0ff74dba@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Chengguang Xu <cgxu519@gmx.com>, mgorman@techsingularity.net, jlayton@redhat.com, ak@linux.intel.com, mawilcox@microsoft.com, tim.c.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>

On Fri 20-07-18 16:14:29, Andrew Morton wrote:
> On Thu, 19 Jul 2018 10:58:12 +0200 Jan Kara <jack@suse.cz> wrote:
> 
> > On Thu 19-07-18 16:17:26, Chengguang Xu wrote:
> > > When we try to truncate read count in generic_file_buffered_read(),
> > > should deliver (sb->s_maxbytes - offset) as maximum count not
> > > sb->s_maxbytes itself.
> > > 
> > > Signed-off-by: Chengguang Xu <cgxu519@gmx.com>
> > 
> > Looks good to me. You can add:
> > 
> > Reviewed-by: Jan Kara <jack@suse.cz>
> 
> Yup.
> 
> What are the runtime effects of this bug?

Good question. I think ->readpage() could be called for index beyond
maximum file size supported by the filesystem leading to weird filesystem
behavior due to overflows in internal calculations.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
