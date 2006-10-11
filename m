From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [RFC] hugetlb: Move hugetlb_get_unmapped_area
Date: Wed, 11 Oct 2006 08:43:38 -0700
Message-ID: <000001c6ed4c$08419150$1680030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1160573520.9894.27.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Adam Litke' <agl@us.ibm.com>, linux-mm <linux-mm@kvack.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Adam Litke wrote on Wednesday, October 11, 2006 6:32 AM
> I am trying to do some hugetlb interface cleanups which include
> separation of the hugetlb utility functions (mostly in mm/hugetlb.c)
> from the hugetlbfs interface to huge pages (fs/hugetlbfs/inode.c).
> 
> This patch simply moves hugetlb_get_unmapped_area() (which I'll argue is
> more of a utility function than an interface) to mm/hugetlb.c.  

To me it doesn't look like a clean up.  get_unmapped_area() is one of
file_operations method and it make sense with the current arrangement
that it stays together with .mmap method, which both live in
fs/hugetlbfs/inode.c.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
