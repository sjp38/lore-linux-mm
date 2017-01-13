Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD3F6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:26:13 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r126so13243265wmr.2
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 00:26:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n25si10362485wrn.35.2017.01.13.00.26.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 00:26:10 -0800 (PST)
Date: Fri, 13 Jan 2017 09:26:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch linux-next] userfaultfd: hugetlbfs: unmap the correct
 pointer
Message-ID: <20170113082607.GA25212@dhcp22.suse.cz>
References: <20170112192052.GB12157@mwanda>
 <20170112193327.GB8558@dhcp22.suse.cz>
 <20170113081610.GC4188@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113081610.GC4188@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Fri 13-01-17 11:16:10, Dan Carpenter wrote:
> On Thu, Jan 12, 2017 at 08:33:27PM +0100, Michal Hocko wrote:
> > On Thu 12-01-17 22:20:52, Dan Carpenter wrote:
> > > kunmap_atomic() and kunmap() take different pointers.  People often get
> > > these mixed up.
> > > 
> > > Fixes: 16374db2e9a0 ("userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing")
> > 
> > This looks like a linux-next sha1. This is not stable and will change...
> > 
> 
> Yeah.  But probably Andrew is just going to fold it into the original
> anyway.  Probably most of linux-next trees don't rebase so the hash is
> good and the people who rebase fold it in so it doesn't show up in the
> released code.  It basically never hurts to have the Fixes tag.

Yeah, I have a vague recollection that some of those sha1 leaked to
Linus. Do not have any examples handy though. It is true that Andrew
folds those fixes into the original patch so it might be helpful to
have
Fixes: mmotm-patch-file-name.patch
instead.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
