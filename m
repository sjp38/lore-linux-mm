Message-ID: <44110727.802@yahoo.com.au>
Date: Fri, 10 Mar 2006 15:57:11 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 03/03] Unmapped: Add guarantee code
References: <20060310034412.8340.90939.sendpatchset@cherry.local> <20060310034429.8340.61997.sendpatchset@cherry.local>
In-Reply-To: <20060310034429.8340.61997.sendpatchset@cherry.local>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Magnus Damm wrote:
> Implement per-LRU guarantee through sysctl.
> 
> This patch introduces the two new sysctl files "node_mapped_guar" and
> "node_unmapped_guar". Each file contains one percentage per node and tells
> the system how many percentage of all pages that should be kept in RAM as 
> unmapped or mapped pages.
> 

The whole Linux VM philosophy until now has been to get away from stuff
like this.

If your app is really that specialised then maybe it can use mlock. If
not, maybe the VM is currently broken.

You do have a real-world workload that is significantly improved by this,
right?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
