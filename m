Message-Id: <200601122006.k0CK6Sg17146@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH 2/2] hugetlb: synchronize alloc with page cache insert
Date: Thu, 12 Jan 2006 12:06:29 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1137095339.17956.22.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Adam Litke' <agl@us.ibm.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adam Litke wrote on Thursday, January 12, 2006 11:49 AM
> On Thu, 2006-01-12 at 11:07 -0800, Chen, Kenneth W wrote:
> > Sorry, I don't think patch 1 by itself is functionally correct.  It opens
> > a can of worms with race window all over the place.  It does more damage
> > than what it is trying to solve.  Here is one case:
> > 
> > 1 thread fault on hugetlb page, allocate a non-zero page, insert into the
> > page cache, then proceed to zero it.  While in the middle of the zeroing,
> > 2nd thread comes along fault on the same hugetlb page.  It find it in the
> > page cache, went ahead install a pte and return to the user.  User code
> > modify some parts of the hugetlb page while the 1st thread is still
> > zeroing.  A potential silent data corruption.
> 
> I don't think the above case is possible because of find_lock_page().
> The second thread would wait on the page to be unlocked by the thread
> zeroing it before it could proceed.

I think you are correct.  Sorry for the noise.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
