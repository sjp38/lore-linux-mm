Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 844846B025E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 15:03:37 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so61261167pad.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 12:03:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q73si2015216pfi.106.2016.06.02.12.03.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 12:03:36 -0700 (PDT)
Date: Thu, 2 Jun 2016 12:03:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG/REGRESSION] THP: broken page count after commit aa88b68c
Message-Id: <20160602120335.4b38dd2bee7b3740ab025f79@linux-foundation.org>
In-Reply-To: <201606021856.u52ImC6o037023@mx0a-001b2d01.pphosted.com>
References: <20160602172141.75c006a9@thinkpad>
	<20160602155149.GB8493@node.shutemov.name>
	<20160602114031.64b178c823901c171ec82745@linux-foundation.org>
	<201606021856.u52ImC6o037023@mx0a-001b2d01.pphosted.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Thu, 2 Jun 2016 20:56:27 +0200 Christian Borntraeger <borntraeger@de.ibm.com> wrote:

> >> The fix looks good to me.
> > 
> > Yes.  A bit regrettable, but that's what release_pages() does.
> > 
> > Can we have a signed-off-by please?
> 
> Please also add CC: stable for 4.6

I shall take that as a "yes" and I'll add

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

to the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
