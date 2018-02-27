Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1AAEE6B0003
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 17:23:51 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 4-v6so206861plb.1
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 14:23:51 -0800 (PST)
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id l29-v6si169244pli.25.2018.02.27.14.23.48
        for <linux-mm@kvack.org>;
        Tue, 27 Feb 2018 14:23:49 -0800 (PST)
Date: Wed, 28 Feb 2018 09:23:45 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 00/12] vfio, dax: prevent long term filesystem-dax
 pins and other fixes
Message-ID: <20180227222345.GK30854@dastard>
References: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jane Chu <jane.chu@oracle.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "supporter:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, Gerd Rausch <gerd.rausch@oracle.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Mon, Feb 26, 2018 at 08:19:54PM -0800, Dan Williams wrote:
> The following series implements...
> Changes since v3 [1]:
> 
> * Kill IS_DAX() in favor of explicit IS_FSDAX() and IS_DEVDAX() helpers.
>   Jan noted, "having IS_DAX() and IS_FSDAX() doing almost the same, just
>   not exactly the same, is IMHO a recipe for confusion", and I agree. A
>   nice side effect of this elimination is a cleanup to remove occasions of
>   "#ifdef CONFIG_FS_DAX" in C files, it is all moved to header files
>   now. (Jan)

Dan, can you please stop sending random patches in a patch set to
random lists?  Your patchsets are hitting 4 or 5 different procmail
filters here and so it gets split across several different mailing
list buckets. It's really annoying to have to go reconstruct every
patch set you send back into a single series in a single bucket....

Can you please fix up your patch set sending again?

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
