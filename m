Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1768C6B007E
	for <linux-mm@kvack.org>; Wed, 11 May 2016 05:19:35 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so36587317wmw.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 02:19:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e15si8627357wmi.67.2016.05.11.02.19.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 May 2016 02:19:33 -0700 (PDT)
Date: Wed, 11 May 2016 11:19:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC v3] [PATCH 0/18] DAX page fault locking
Message-ID: <20160511091930.GE14744@quack2.suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <20160506203308.GA12506@linux.intel.com>
 <20160509093828.GF11897@quack2.suse.cz>
 <20160510152814.GQ11897@quack2.suse.cz>
 <20160510203003.GA5314@linux.intel.com>
 <20160510223937.GA10222@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
In-Reply-To: <20160510223937.GA10222@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 10-05-16 16:39:37, Ross Zwisler wrote:
> On Tue, May 10, 2016 at 02:30:03PM -0600, Ross Zwisler wrote:
> > On Tue, May 10, 2016 at 05:28:14PM +0200, Jan Kara wrote:
> > > On Mon 09-05-16 11:38:28, Jan Kara wrote:
> > > Somehow, I'm not able to reproduce the warnings... Anyway, I think I see
> > > what's going on. Can you check whether the warning goes away when you
> > > change the condition at the end of page_cache_tree_delete() to:
> > > 
> > >         if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
> > >             list_empty(&node->private_list)) {
> > 
> > Yep, this took care of both of the issues that I reported.  I'll restart my
> > testing with this in my baseline, but as of this fix I don't have any more
> > open testing issues. :)
> 
> Well, looks like I spoke too soon.  The two tests that were failing for me are
> now passing, but I can still create what looks like a related failure using
> XFS, DAX, and the two xfstests generic/231 and generic/232 run back-to-back.

Hum, full xfstests run completes for me just fine. Can you reproduce the
issue with the attached debug patch? Thanks!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--LQksG6bCIzRHxTLp
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-Debugging-workingset.patch"


--LQksG6bCIzRHxTLp--
