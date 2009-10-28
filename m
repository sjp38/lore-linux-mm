Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C0D8B6B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 10:53:32 -0400 (EDT)
Received: by ey-out-1920.google.com with SMTP id 5so202632eyb.6
        for <linux-mm@kvack.org>; Wed, 28 Oct 2009 07:53:30 -0700 (PDT)
Date: Wed, 28 Oct 2009 17:53:25 +0300
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [patch -mm] acpi: remove NID_INVAL
Message-ID: <20091028145325.GA5316@lenovo>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162533.23192.71981.sendpatchset@localhost.localdomain> <alpine.DEB.1.10.0910081616040.8030@gentwo.org> <alpine.DEB.1.00.0910081325200.6998@chino.kir.corp.google.com> <alpine.DEB.2.00.0910271442250.30270@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910271442250.30270@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-numa@vger.kernel.org, Len Brown <lenb@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

[David Rientjes - Tue, Oct 27, 2009 at 02:44:14PM -0700]
| NUMA_NO_NODE has been exported globally and thus it can replace NID_INVAL
| in the acpi code.
| 
| Also removes the unused acpi_unmap_pxm_to_node() function.
| 
| Cc: Len Brown <lenb@kernel.org>
| Cc: Cyrill Gorcunov <gorcunov@openvz.org>
| Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
| Signed-off-by: David Rientjes <rientjes@google.com>
| ---
|  Depends on Lee Schermerhorn's hugetlb patchset in mmotm-10132113.
| 

Thanks David! My Ack if needed.

	-- Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
