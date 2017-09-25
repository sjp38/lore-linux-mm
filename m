Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6486B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 08:36:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f84so13307934pfj.0
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 05:36:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e15si4075654pgq.471.2017.09.25.05.36.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 05:36:22 -0700 (PDT)
Date: Mon, 25 Sep 2017 14:36:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mremap.2: Add description of old_size == 0
 functionality
Message-ID: <20170925123621.35godwzhvw4wbisc@dhcp22.suse.cz>
References: <a5d279cb-a015-f74c-2e40-a231aa7f7a8c@redhat.com>
 <20170919214224.19561-1-mike.kravetz@oracle.com>
 <6fafdae8-4fea-c967-f5cd-d22c205608fa@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6fafdae8-4fea-c967-f5cd-d22c205608fa@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Jann Horn <jannh@google.com>, Florian Weimer <fweimer@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Wed 20-09-17 09:25:42, Michael Kerrisk wrote:
[...]
>     BUGS
>        Before Linux 4.14, if old_size was zero and the  mapping  referred
>        to  by  old_address  was  a private mapping (mmap(2) MAP_PRIVATE),
>        mremap() created a new private mapping unrelated to  the  original
>        mapping.   This behavior was unintended and probably unexpected in
>        user-space applications (since the intention  of  mremap()  is  to
>        create  a new mapping based on the original mapping).  Since Linux
>        4.14, mremap() fails with the error EINVAL in this scenario.
> 
> Does that seem okay?

sorry to be late but yes this wording makes perfect sense to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
