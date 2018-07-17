Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id EDA9F6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:44:29 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m25-v6so283636pgv.22
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 03:44:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u11-v6si767570plm.143.2018.07.17.03.44.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 03:44:28 -0700 (PDT)
Date: Tue, 17 Jul 2018 12:44:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: Fix vma_is_anonymous() false-positives
Message-ID: <20180717104424.GA7193@dhcp22.suse.cz>
References: <20180710134821.84709-2-kirill.shutemov@linux.intel.com>
 <20180710134858.3506f097104859b533c81bf3@linux-foundation.org>
 <20180716133028.GQ17280@dhcp22.suse.cz>
 <20180716140440.fd3sjw5xys5wozw7@black.fi.intel.com>
 <20180716142245.GT17280@dhcp22.suse.cz>
 <20180716144739.que5362bofty6ocp@kshutemo-mobl1>
 <20180716174042.GA17280@dhcp22.suse.cz>
 <20180716203846.roolhtesloabxr2g@kshutemo-mobl1>
 <20180717090053.GE16803@dhcp22.suse.cz>
 <20180717093030.cu2jyuw5kuw7nvwo@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717093030.cu2jyuw5kuw7nvwo@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue 17-07-18 12:30:30, Kirill A. Shutemov wrote:
[...]
> You propose quite a big redesign on how we handle anonymous VMAs.
> Feel free to propose the patch(set). But I don't think it would fly for
> stable@.

OK, fair enough. I thought this would be much easier in the end but I
admit I haven't tried that so I might have underestimated the whole
thing.
-- 
Michal Hocko
SUSE Labs
