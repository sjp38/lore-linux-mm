Message-Id: <7E5B6DFB-F9DE-4929-8A4F-8011BF817017@kernel.crashing.org>
From: Kumar Gala <galak@kernel.crashing.org>
In-Reply-To: <1222789675.13978.14.camel@localhost.localdomain>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Apple Message framework v929.2)
Subject: Re: [PATCH] properly reserve in bootmem the lmb reserved regions that cross numa nodes
Date: Wed, 1 Oct 2008 16:02:33 -0500
References: <48E23D6C.4030406@linux.vnet.ibm.com> <1222789675.13978.14.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, linuxppc-dev <linuxppc-dev@ozlabs.org>, Adam Litke <agl@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Out of interest how to do you guys represent NUMA regions of memory in  
the device tree?

- k

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
