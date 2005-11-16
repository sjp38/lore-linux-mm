Date: Wed, 16 Nov 2005 22:59:53 +0000
Subject: [PATCH 0/3] SPARSEMEM: pfn_to_nid implementation
Message-ID: <exportbomb.1132181992@pinky>
References: <20051115221003.GA2160@w-mikek2.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Anton Blanchard <anton@samba.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have reviewed the uses of pfn_to_nid() in 2.6.14-mm2.  The only
user of the non-init pfn_to_nid is the one in check_pte_range().
So we simply need to profide a non-early pfn_to_nid() implementation
for SPARSEMEM.  Whilst reviewing these interfaces I found two
alternative dependant interfaces which are not used.

Following this message are three patches:

kvaddr_to_nid-not-used-in-common-code: removes the unused interface
kvaddr_to_nid().

pfn_to_pgdat-not-used-in-common-code: removes the unused interface
pfn_to_pgdat().

sparse-provide-pfn_to_nid: provides pfn_to_nid() for SPARSEMEM.
Note that this implmentation assumes the pfn has been validated
prior to use.  The only intree user of this call does this.
We perhaps need to make this part of the signature for this function.

Mike, how does this look to you?

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
