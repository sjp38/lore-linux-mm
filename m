Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADE6E440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 12:13:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t20so1353555wmt.4
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:13:49 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r128si1833651wmf.233.2017.08.24.09.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 09:13:48 -0700 (PDT)
Date: Thu, 24 Aug 2017 18:13:47 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v6 2/5] fs, xfs: introduce S_IOMAP_SEALED
Message-ID: <20170824161347.GC27591@lst.de>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com> <150353212577.5039.14069456126848863439.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150353212577.5039.14069456126848863439.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

I'm still very unhappy about the get/set flag state.  What is the
reason you can't use/extend leases? (take a look at the fcntl
man page and look for Leases).  A variant of the concept is what
the pNFS block server uses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
