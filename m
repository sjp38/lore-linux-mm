Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E93B2808C5
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 09:21:46 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id d88so19466757ybi.3
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 06:21:46 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id e184si862557ywh.383.2017.03.09.06.21.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 06:21:45 -0800 (PST)
Date: Thu, 9 Mar 2017 09:21:37 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 0/3] mm/fs: get PG_error out of the writeback reporting
 business
Message-ID: <20170309142137.lz7cba4was3jfyyt@thunk.org>
References: <20170305133535.6516-1-jlayton@redhat.com>
 <1488724854.2925.6.camel@redhat.com>
 <20170306230801.GA28111@linux.intel.com>
 <20170307102622.GB2578@quack2.suse.cz>
 <20170309025725.5wrszri462zipiix@thunk.org>
 <20170309090449.GD15874@quack2.suse.cz>
 <1489056471.2791.2.camel@redhat.com>
 <20170309110225.GF15874@quack2.suse.cz>
 <1489063392.2791.8.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489063392.2791.8.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, viro@zeniv.linux.org.uk, konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, NeilBrown <neilb@suse.com>

On Thu, Mar 09, 2017 at 07:43:12AM -0500, Jeff Layton wrote:
> 
> Maybe we need a systemwide (or fs-level) tunable that makes ENOSPC a
> transient error? Just have it hang until we get enough space when that
> tunable is enabled?

Or maybe we need a new kernel-internal errno (ala ERESTARSYS) which
means it's a "soft ENOSPC"?  It would get translated to ENOSPC if it
gets propagated to userspace, but that way for devices like dm-thin or
other storage array with thin volumes, it could send back a soft
ENOSPC, while for file systems where "ENOSPC means ENOSPC", we can
treat those as a hard ENOSPC.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
