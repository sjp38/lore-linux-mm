Message-Id: <200601112346.k0BNk5g02008@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH 2/2] hugetlb: synchronize alloc with page cache insert
Date: Wed, 11 Jan 2006 15:46:05 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1137020606.9672.16.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Adam Litke' <agl@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adam Litke wrote on Wednesday, January 11, 2006 3:03 PM
> Nope, all the i_blocks stuff is gone.  I was just looking for a
> spin_lock for serializing all allocations for a particular hugeltbfs
> file and i_lock seemed to fit that bill.

I hope you are aware of the consequence of serializing page allocation:
It won't scale on large numa machine.  I don't have any issue per se at
the moment.  But in the past, SGI folks had screamed their heads off
for people doing something like that.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
