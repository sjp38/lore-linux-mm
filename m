Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F25C86B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 07:52:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so11984848wmw.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 04:52:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pd2si2158826wjb.233.2016.05.10.04.52.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 04:52:13 -0700 (PDT)
Date: Tue, 10 May 2016 13:52:10 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC v3] [PATCH 0/18] DAX page fault locking
Message-ID: <20160510115210.GJ11897@quack2.suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1462829283.3149.7.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462829283.3149.7.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "jack@suse.cz" <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ted Tso <tytso@mit.edu>

Hi!

On Mon 09-05-16 21:28:06, Verma, Vishal L wrote:
> On Mon, 2016-04-18 at 23:35 +0200, Jan Kara wrote:
> I've noticed that patches 1 through 12 of your series are relatively
> independent, and are probably more stable than the remaining part of
> the series that actually changes locking.

Yes.

> My dax error handling series also depends on the patches that change
> zeroing in DAX (patches 5, 6, 9).
> 
> To allow the error handling stuff to move faster, can we split these
> into two patchsets?
>
> I was hoping to send the dax error handling series through the nvdimm
> tree, and if you'd like, I can also prepend your patches 1-12 with my
> series.

So I'm thinking how to best merge this. There are some ext4 patches which
are not trivial (mainly "ext4: Refactor direct IO code"). These can go in
as far as I'm concerned but there is a potential for conflicts in ext4
tree and I'd definitely want to give them full test run in the ext4 tree.
The best what I can think of is to pull ext4 related changes into a stable
branch in ext4 tree and then pull that branch into nvdimm tree. Ted, what
do you think? If you agree, I can separate the patches into three parts -
one for ext4 tree, stable patches for nvdimm tree, and then remaining
patches.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
