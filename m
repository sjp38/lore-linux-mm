Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2093C6B02C3
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:47:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s65so27626707pfi.14
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:47:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l67si4079pgl.376.2017.06.13.23.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 23:47:58 -0700 (PDT)
Date: Tue, 13 Jun 2017 23:47:31 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 12/20] fs: add a new fstype flag to indicate how
 writeback errors are tracked
Message-ID: <20170614064731.GB3598@infradead.org>
References: <20170612122316.13244-1-jlayton@redhat.com>
 <20170612122316.13244-15-jlayton@redhat.com>
 <20170612124513.GC18360@infradead.org>
 <1497349472.5762.1.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497349472.5762.1.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Tue, Jun 13, 2017 at 06:24:32AM -0400, Jeff Layton wrote:
> That's definitely what I want for the endgame here. My plan was to add
> this flag for now, and then eventually reverse it (or drop it) once all
> or most filesystems are converted.
> 
> We can do it that way from the get-go if you like. It'll mean tossing in
>  a patch add this flag to all filesystems that have an fsync operation
> and that use the pagecache, and then gradually remove it from them as we
> convert them.
> 
> Which method do you prefer?

Please do it from the get-go.  Or in fact figure out if we can get
away without it entirely.  Moving the error reporting into ->fsync
should help greatly with that, so what's missing after that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
