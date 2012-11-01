Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id EC6106B0085
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 18:24:14 -0400 (EDT)
Message-ID: <5092F67A.2060203@panasas.com>
Date: Thu, 1 Nov 2012 15:23:54 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] fs: Fix remaining filesystems to wait for stable
 page writeback
References: <20121101075805.16153.64714.stgit@blackbox.djwong.org> <20121101075829.16153.92036.stgit@blackbox.djwong.org> <5092C2CE.7070209@panasas.com> <20121101162254.03dbbd9a@tlielax.poochiereds.net>
In-Reply-To: <20121101162254.03dbbd9a@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@samba.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, axboe@kernel.dk, lucho@ionkov.net, tytso@mit.edu, sage@inktank.com, ericvh@gmail.com, mfasheh@suse.com, dedekind1@gmail.com, adrian.hunter@intel.com, dhowells@redhat.com, sfrench@samba.org, jlbec@evilplan.org, rminnich@sandia.gov, linux-cifs@vger.kernel.org, jack@suse.cz, martin.petersen@oracle.com, neilb@suse.de, david@fromorbit.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, v9fs-developer@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-afs@lists.infradead.org, ocfs2-devel@oss.oracle.com

On 11/01/2012 01:22 PM, Jeff Layton wrote:
> Hmm...I don't know...
> 
> I've never been crazy about using the page lock for this, but in the
> absence of a better way to guarantee stable pages, it was what I ended
> up with at the time. cifs_writepages will hold the page lock until
> kernel_sendmsg returns. At that point the TCP layer will have copied
> off the page data so it's safe to release it.
> 
> With this change though, we're going to end up blocking until the
> writeback flag clears, right? And I think that will happen when the
> reply comes in? So, we'll end up blocking for much longer than is
> really necessary in page_mkwrite with this change.
> 

Hmm OK, that is a very good point. In that case it is just a simple
nack on Darrick's hunk to cifs. cifs is fine and should not be touched

Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
