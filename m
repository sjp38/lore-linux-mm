Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id l93J3bRe008261
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 20:03:37 +0100
Received: from an-out-0708.google.com (andd40.prod.google.com [10.100.30.40])
	by zps36.corp.google.com with ESMTP id l93J3XIS011700
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 12:03:36 -0700
Received: by an-out-0708.google.com with SMTP id d40so717605and
        for <linux-mm@kvack.org>; Wed, 03 Oct 2007 12:03:36 -0700 (PDT)
Message-ID: <b040c32a0710031203s7cc7b84fyab907046d2d3c773@mail.gmail.com>
Date: Wed, 3 Oct 2007 12:03:36 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH] hugetlb: Fix pool resizing corner case
In-Reply-To: <1191436392.19775.43.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071003154748.19516.90317.stgit@kernel>
	 <1191433248.4939.79.camel@localhost>
	 <1191436392.19775.43.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 10/3/07, Adam Litke <agl@us.ibm.com> wrote:
> The key is that we don't want to shrink the pool below the number of
> pages we are committed to keeping around.  Before this patch, we only
> accounted for the pages we plan to hand out (reserved huge pages) but
> not the ones we've already handed out (total - free).  Does that make
> sense?

Good catch, adam.

>From what I can see, the statement
        if (count >= nr_huge_pages)
                return nr_huge_pages;

in set_max_huge_pages() is useless because (1) we recalculate "count"
variable below it; and (2) both try_to_free_low() and the while loop
below the call to try_to_free_low() will terminate correctly.  If you
feel like it, please clean it up as well.

If not, I'm fine with that.

Acked-by: Ken Chen <kenchen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
