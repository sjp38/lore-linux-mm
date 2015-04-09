Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 953C76B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 15:46:11 -0400 (EDT)
Received: by iejt8 with SMTP id t8so879848iej.2
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 12:46:11 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id 186si3410534ioe.57.2015.04.09.12.46.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 12:46:11 -0700 (PDT)
Received: by iebmp1 with SMTP id mp1so971648ieb.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 12:46:11 -0700 (PDT)
Date: Thu, 9 Apr 2015 12:46:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, doc: cleanup and clarify munmap behavior for
 hugetlb memory fix
In-Reply-To: <20150404113456.55468dc3@lwn.net>
Message-ID: <alpine.DEB.2.10.1504091244501.11370@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com> <alpine.LSU.2.11.1503291801400.1052@eggly.anvils> <alpine.DEB.2.10.1504021536210.15536@chino.kir.corp.google.com> <alpine.DEB.2.10.1504021547330.15536@chino.kir.corp.google.com>
 <20150404113456.55468dc3@lwn.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org

On Sat, 4 Apr 2015, Jonathan Corbet wrote:

> On Thu, 2 Apr 2015 15:50:15 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > Don't only specify munmap(2) behavior with respect the hugetlb memory, all 
> > other syscalls get naturally aligned to the native page size of the 
> > processor.  Rather, pick out munmap(2) as a specific example.
> 
> So I was going to apply this to the docs tree, but it doesn't even come
> close.  What tree was this patch generated against?
> 

Sorry, it's not intended to go through the docs tree, it's a patch to fix 
mm-doc-cleanup-and-clarify-munmap-behavior-for-hugetlb-memory.patch in 
-mm.  It's been merged into that tree, but I would still appreciate your 
ack!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
