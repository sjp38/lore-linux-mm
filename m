Message-Id: <200510262012.j9QKCUg23575@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: RFC: Cleanup / small fixes to hugetlb fault handling
Date: Wed, 26 Oct 2005 13:12:30 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20051026024831.GB17191@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, William Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

David Gibson wrote on Tuesday, October 25, 2005 7:49 PM
> - find_lock_huge_page() didn't, in fact, lock the page if it newly
>   allocated one, rather than finding it in the page cache already.  As
>   far as I can tell this is a bug, so the patch corrects it.

add_to_page_cache will lock the page if it was successfully added to the
address space radix tree.  I don't see a bug that you are seeing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
