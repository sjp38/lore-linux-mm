Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id l93J8rpZ025798
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 12:08:53 -0700
Received: from an-out-0708.google.com (ancc14.prod.google.com [10.100.29.14])
	by zps37.corp.google.com with ESMTP id l93J8riQ005349
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 12:08:53 -0700
Received: by an-out-0708.google.com with SMTP id c14so953303anc
        for <linux-mm@kvack.org>; Wed, 03 Oct 2007 12:08:52 -0700 (PDT)
Message-ID: <b040c32a0710031208s5323d16ao47becace88c2bc79@mail.gmail.com>
Date: Wed, 3 Oct 2007 12:08:52 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH] hugetlb: Fix pool resizing corner case
In-Reply-To: <1191437948.4939.105.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071003154748.19516.90317.stgit@kernel>
	 <1191433248.4939.79.camel@localhost>
	 <1191436392.19775.43.camel@localhost.localdomain>
	 <1191437948.4939.105.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 10/3/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> > Not quite.  Count can never go below the number of reserved pages plus
> > pages allocated to MAP_PRIVATE mappings.  That number is computed by:
> > (resv + (total - free)).
>
> So, (total - free) equals the number of MAP_PRIVATE pages?  Does that
> imply that all reserved pages are shared and that all shared pages are
> reserved?

no, not quite.  In-use huge page (total - free) can be both private or
shared.  resv_huge_pages counts number of pages that is committed for
shared mapping, but not yet faulted in.

What the equation does essentially is: resv_huge_pages + nr-huge-pages-in-use.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
