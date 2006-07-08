Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.6/8.13.6) with ESMTP id k68Bhoja160262
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 8 Jul 2006 11:43:50 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k68BkcJe084850
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Sat, 8 Jul 2006 13:46:38 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k68Bhn07026892
	for <linux-mm@kvack.org>; Sat, 8 Jul 2006 13:43:50 +0200
Date: Sat, 8 Jul 2006 13:42:01 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 0/6] Sizing zones and holes in an architecture independent manner V8
Message-ID: <20060708114201.GA9419@osiris.boeblingen.de.ibm.com>
References: <20060708111042.28664.14732.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060708111042.28664.14732.sendpatchset@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, davej@codemonkey.org.uk, tony.luck@intel.com, ak@suse.de, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 08, 2006 at 12:10:42PM +0100, Mel Gorman wrote:
> There are differences in the zone sizes for x86_64 as the arch-specific code
> for x86_64 accounts the kernel image and the starting mem_maps as memory
> holes but the architecture-independent code accounts the memory as present.

Shouldn't this be the same for all architectures? Or to put it in other words:
why does only x86_64 account the kernel image as memory hole?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
