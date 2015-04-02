Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 686836B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 18:40:59 -0400 (EDT)
Received: by igcxg11 with SMTP id xg11so85485899igc.0
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 15:40:59 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id o64si5603186ioo.84.2015.04.02.15.40.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 15:40:58 -0700 (PDT)
Received: by ignm3 with SMTP id m3so56741073ign.0
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 15:40:58 -0700 (PDT)
Date: Thu, 2 Apr 2015 15:40:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, doc: cleanup and clarify munmap behavior for
 hugetlb memory
In-Reply-To: <alpine.LSU.2.11.1503291801400.1052@eggly.anvils>
Message-ID: <alpine.DEB.2.10.1504021536210.15536@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com> <alpine.LSU.2.11.1503291801400.1052@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org

On Sun, 29 Mar 2015, Hugh Dickins wrote:

> > munmap(2) of hugetlb memory requires a length that is hugepage aligned,
> > otherwise it may fail.  Add this to the documentation.
> 
> Thanks for taking this on, David.  But although munmap(2) is the one
> Davide called out, it goes beyond that, doesn't it?  To mprotect and
> madvise and ...
> 

Yes, good point, munmap(2) isn't special in this case, the alignment to 
the native page size of the platform should apply to madvise, mbind, 
mincore, mlock, mprotect, remap_file_pages, etc.

I'd hesitate to compile any authoritative list on the behavior in 
Documentation/vm/hugetlbpage.txt since it would exclude future extensions, 
but I'll update it to be more inclusive of other mm syscalls rather than 
specify only munmap(2).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
