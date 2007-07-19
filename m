Date: Thu, 19 Jul 2007 10:52:07 -0700
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: [PATCH] hugetlbfs read() support
Message-ID: <20070719175207.GH26380@holomorphy.com>
References: <1184376214.15968.9.camel@dyn9047017100.beaverton.ibm.com> <20070718221950.35bbdb76.akpm@linux-foundation.org> <1184860309.18188.90.camel@dyn9047017100.beaverton.ibm.com> <20070719095850.6e09b0e8.akpm@linux-foundation.org> <20070719170759.GE2083@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070719170759.GE2083@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Bill Irwin <bill.irwin@oracle.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 19, 2007 at 10:07:59AM -0700, Nishanth Aravamudan wrote:
> But I do think a second reason to do this is to make hugetlbfs behave
> like a normal fs -- that is read(), write(), etc. work on files in the
> mountpoint. But that is simply my opinion.

Mine as well.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
