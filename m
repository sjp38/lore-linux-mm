Date: Thu, 2 Aug 2007 06:05:50 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] hugetlb: allow extending ftruncate on hugetlbfs
Message-ID: <20070802130550.GQ11781@holomorphy.com>
References: <b040c32a0708011636x74f61aefvf2ecaa280cc990fc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b040c32a0708011636x74f61aefvf2ecaa280cc990fc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 01, 2007 at 04:36:15PM -0700, Ken Chen wrote:
> For historical reason, expanding ftruncate that increases file size on
> hugetlbfs is not allowed due to pages were pre-faulted and lack of
> fault handler.  Now that we have demand faulting on hugetlb since
> 2.6.15, there is no reason to hold back that limitation.
> This will make hugetlbfs behave more like a normal fs. I'm writing a
> user level code that uses hugetlbfs but will fall back to tmpfs if
> there are no hugetlb page available in the system.  Having hugetlbfs
> specific ftruncate behavior is a bit quirky and I would like to remove
> that artificial limitation.
> Signed-off-by: <kenchen@google.com>

Excellent, thank you.

Acked-by: Wiliam Irwin <wli@holomorphy.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
