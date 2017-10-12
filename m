Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9ACF96B026F
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 21:21:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h191so1781023wmd.15
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 18:21:44 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id w18si11897814wra.216.2017.10.11.18.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 18:21:42 -0700 (PDT)
Date: Thu, 12 Oct 2017 02:21:32 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v9 2/6] fs, mm: pass fd to ->mmap_validate()
Message-ID: <20171012012131.GD21978@ZenIV.linux.org.uk>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150776923838.9144.15727770472447035032.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150776923838.9144.15727770472447035032.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Oct 11, 2017 at 05:47:18PM -0700, Dan Williams wrote:
> The MAP_DIRECT mechanism for mmap intends to use a file lease to prevent
> block map changes while the file is mapped. It requires the fd to setup
> an fasync_struct for signalling lease break events to the lease holder.

*UGH*

That looks like one hell of a bad API.  You are not even guaranteed that
descriptor will remain be still open by the time you pass it down to your
helper, nevermind the moment when event actually happens...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
