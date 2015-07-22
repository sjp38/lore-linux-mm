Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 30AB19003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:30:57 -0400 (EDT)
Received: by igr7 with SMTP id 7so79672544igr.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:30:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m197si2685570iom.125.2015.07.22.15.30.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 15:30:56 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:30:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 09/10] hugetlbfs: add hugetlbfs_fallocate()
Message-Id: <20150722153055.7431aeb4c39dadf02ca06d4c@linux-foundation.org>
In-Reply-To: <55B017EE.5020203@oracle.com>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
	<1437502184-14269-10-git-send-email-mike.kravetz@oracle.com>
	<20150722150345.f8d5b0042cfa7112bd95d9ef@linux-foundation.org>
	<55B017EE.5020203@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 22 Jul 2015 15:23:42 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> On 07/22/2015 03:03 PM, Andrew Morton wrote:
> > On Tue, 21 Jul 2015 11:09:43 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> ...
> >> +
> >> +	if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE))
> >> +		return -EOPNOTSUPP;
> >
> > EOPNOTSUPP is a networking thing.  It's inappropriate here.
> >
> > The problem is that if this error is ever returned to userspace, the
> > user will be sitting looking at "Operation not supported on transport
> > endpoint" and wondering what went wrong in the networking stack.
> 
> Trying to follow FALLOCATE(2) man page:
> 
> "EOPNOTSUPP
> 	The filesystem containing the file referred to by  fd  does  not
> 	support  this  operation;  or  the  mode is not supported by the
> 	filesystem containing the file referred to by fd."
> 

Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
