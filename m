Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6C12E6B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 21:37:49 -0400 (EDT)
Received: by iecvj10 with SMTP id vj10so83376760iec.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 18:37:49 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id v8si3210354igb.51.2015.03.27.18.37.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 18:37:48 -0700 (PDT)
Received: by igcau2 with SMTP id au2so41326774igc.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 18:37:48 -0700 (PDT)
Date: Fri, 27 Mar 2015 18:37:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, doc: cleanup and clarify munmap behavior for
 hugetlb memory
In-Reply-To: <20150327135847.GB10747@akamai.com>
Message-ID: <alpine.DEB.2.10.1503271833360.5628@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com> <20150327135847.GB10747@akamai.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org

On Fri, 27 Mar 2015, Eric B Munson wrote:

> > munmap(2) of hugetlb memory requires a length that is hugepage aligned,
> > otherwise it may fail.  Add this to the documentation.
> > 
> > This also cleans up the documentation and separates it into logical
> > units: one part refers to MAP_HUGETLB and another part refers to
> > requirements for shared memory segments.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> 
> If this is the route we are going to take, this behavoir needs to be
> called out prominently in the mmap/munmap man page.
> 

Yeah, that was my next step, but before we get mtk involved I was trying 
to get this merged since man2/mmap.2 already has a 
.I Documentation/vm/hugetlbpage.txt for MAP_HUGETLB so the man page patch 
can simply reference this addition to the file as justification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
