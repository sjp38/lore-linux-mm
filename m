Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1FB2808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 09:46:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y43so9269599wrc.11
        for <linux-mm@kvack.org>; Wed, 10 May 2017 06:46:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n82si4183567wmg.74.2017.05.10.06.46.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 06:46:39 -0700 (PDT)
Date: Wed, 10 May 2017 15:46:36 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 14/27] fs: new infrastructure for writeback error
 handling and reporting
Message-ID: <20170510134636.GA3883@quack2.suse.cz>
References: <20170509154930.29524-1-jlayton@redhat.com>
 <20170509154930.29524-15-jlayton@redhat.com>
 <20170510114840.GF25137@quack2.suse.cz>
 <1494418790.2688.7.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494418790.2688.7.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

On Wed 10-05-17 08:19:50, Jeff Layton wrote:
> On Wed, 2017-05-10 at 13:48 +0200, Jan Kara wrote:
> > On Tue 09-05-17 11:49:17, Jeff Layton wrote:
> > > diff --git a/fs/file_table.c b/fs/file_table.c
> > > index 954d510b765a..d6138b6411ff 100644
> > > --- a/fs/file_table.c
> > > +++ b/fs/file_table.c
> > > @@ -168,6 +168,7 @@ struct file *alloc_file(const struct path *path, fmode_t mode,
> > >  	file->f_path = *path;
> > >  	file->f_inode = path->dentry->d_inode;
> > >  	file->f_mapping = path->dentry->d_inode->i_mapping;
> > > +	file->f_wb_err = filemap_sample_wb_error(file->f_mapping);
> > 
> > Why do you sample here when you also sample in do_dentry_open()? I didn't
> > find any alloc_file() callers that would possibly care about writeback
> > errors... 
> > 
> > 								Honza
> 
> I basically used the setting of f_mapping as a guideline as to where to
> sample it for initialization. My thinking was that if f_mapping ever
> ended up different then you'd probably also want f_wb_err to be
> resampled anyway.

OK, makes sense.

> I can drop this hunk if you think we don't need it.

I don't really care. I was just wondering whether I'm missing something...

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
