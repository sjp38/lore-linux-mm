Message-Id: <200603070030.k270UNg17446@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] hugetlb: remove sysctl zero and infinity values
Date: Mon, 6 Mar 2006 16:30:23 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060306224954.4400F11C@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Dave Hansen' <haveblue@us.ibm.com>, wli@holomorphy.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote on Monday, March 06, 2006 2:50 PM
> There's also something a little bit fishy with putting
> max_huge_pages in the sysctl table _and_ setting it manually
> in the handler function.  But, I'll leave that for another day.

max_huge_pages looks OK, maybe it has a bad name.  Because that is
a variable used to pass desired hugetlb pool size by sys admin. It
is used only in the reservation path.  Kernel pretty much needs at
least two variables: what is the desired target and what is current
reservation state (that tracked by nr_huge_pages).

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
