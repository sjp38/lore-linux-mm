Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4D66B0260
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 04:17:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a43so2891537wrc.2
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 01:17:28 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n6si5822061wmd.160.2017.10.01.01.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Oct 2017 01:17:27 -0700 (PDT)
Date: Sun, 1 Oct 2017 10:17:26 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 3/7] xfs: protect S_DAX transitions in XFS read path
Message-ID: <20171001081726.GD11895@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com> <20170925231404.32723-4-ross.zwisler@linux.intel.com> <20170926063234.GA6870@lst.de> <CAPcyv4hKb1PshbjLxyWz2fdj=dK2fi2qgJLFaT9pVnmaOoWV6g@mail.gmail.com> <20170926143357.GA18758@lst.de> <CAPcyv4g=oPXgNJs0E15y_wAKMOMC32Jfjw4HxWGSH+OLss-efg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g=oPXgNJs0E15y_wAKMOMC32Jfjw4HxWGSH+OLss-efg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 11:11:55AM -0700, Dan Williams wrote:
> I think we'll always need an explicit override available, but yes we
> need to think about what the override looks like in the context of a
> kernel that is able to automatically pick the right I/O policy
> relative to the media type. A potential mixed policy for reads vs
> writes makes sense. Where would this finer grained I/O policy
> selection go other than more inode flags?

fadvise?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
