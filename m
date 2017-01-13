Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 454456B0253
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:41:42 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id j82so38701581ybg.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 00:41:42 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u61si3457551ybi.182.2017.01.13.00.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 00:41:41 -0800 (PST)
Date: Fri, 13 Jan 2017 11:40:08 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch linux-next] userfaultfd: hugetlbfs: unmap the correct
 pointer
Message-ID: <20170113084008.GD4188@mwanda>
References: <20170112192052.GB12157@mwanda>
 <20170112193327.GB8558@dhcp22.suse.cz>
 <20170113081610.GC4188@mwanda>
 <20170113082607.GA25212@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113082607.GA25212@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Fri, Jan 13, 2017 at 09:26:08AM +0100, Michal Hocko wrote:
> On Fri 13-01-17 11:16:10, Dan Carpenter wrote:
> > On Thu, Jan 12, 2017 at 08:33:27PM +0100, Michal Hocko wrote:
> > > On Thu 12-01-17 22:20:52, Dan Carpenter wrote:
> > > > kunmap_atomic() and kunmap() take different pointers.  People often get
> > > > these mixed up.
> > > > 
> > > > Fixes: 16374db2e9a0 ("userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing")
> > > 
> > > This looks like a linux-next sha1. This is not stable and will change...
> > > 
> > 
> > Yeah.  But probably Andrew is just going to fold it into the original
> > anyway.  Probably most of linux-next trees don't rebase so the hash is
> > good and the people who rebase fold it in so it doesn't show up in the
> > released code.  It basically never hurts to have the Fixes tag.
> 
> Yeah, I have a vague recollection that some of those sha1 leaked to
> Linus. Do not have any examples handy though. It is true that Andrew
> folds those fixes into the original patch so it might be helpful to
> have
> Fixes: mmotm-patch-file-name.patch

I have no idea how to do that.  I'm always just working on linux-next
and not the individual trees...  I'm interested to hear from Andrew
what's easiest because I don't know at all how quilt works.

My work flow is that I have scripts to generate patches from within vim.
Most of the time I'm just working on one file but occasionally I will
combine two patches together in mutt.

For Dave's networking patches I have a separate git tree where I try to
apply them to net and then net-next to see which tree it should go into.
Otherwise, I generally assume the maintainer knows which tree they
belong in.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
