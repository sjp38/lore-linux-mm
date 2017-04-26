Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F29E6B02F2
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 14:00:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t7so4395630pgt.6
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 11:00:23 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o64si1177187pga.16.2017.04.26.11.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 11:00:22 -0700 (PDT)
Date: Wed, 26 Apr 2017 12:00:21 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 2/2] dax: add regression test for stale mmap reads
Message-ID: <20170426180021.GB15921@linux.intel.com>
References: <20170425205106.20576-1-ross.zwisler@linux.intel.com>
 <20170425205106.20576-2-ross.zwisler@linux.intel.com>
 <20170426090907.q5jj3ywsvldsbq7n@XZHOUW.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170426090907.q5jj3ywsvldsbq7n@XZHOUW.usersys.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiong Zhou <xzhou@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, fstests@vger.kernel.org, jmoyer@redhat.com, eguan@redhat.com, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Apr 26, 2017 at 05:09:07PM +0800, Xiong Zhou wrote:
> On Tue, Apr 25, 2017 at 02:51:06PM -0600, Ross Zwisler wrote:
<>
> > +	/*
> > +	 * Try and use the mmap to read back the data we just wrote with
> > +	 * pwrite().  If the kernel bug is present the mapping from the 2MiB
> > +	 * zero page will still be intact, and we'll read back zeros instead.
> > +	 */
> > +	if (strncmp(buffer, data, strlen(buffer))) {
> > +		fprintf(stderr, "strncmp mismatch: '%s' vs '%s'\n", buffer,
> > +				data);
> 		munmap
> 		close(fd);
> > +		exit(1);
> > +	}
> > +
> 	munmap

Yep, thanks, fixed in v3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
