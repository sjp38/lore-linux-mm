Message-ID: <4724FC38.30909@linux.vnet.ibm.com>
Date: Mon, 29 Oct 2007 02:46:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: OOM notifications
References: <20071018201531.GA5938@dmt> <20071026140201.ae52757c.akpm@linux-foundation.org>
In-Reply-To: <20071026140201.ae52757c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, drepper@redhat.com, riel@redhat.com, Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> It get more complicated with NUMA memory nodes and cgroup memory
> controllers.
> 

At OLS this year, users wanted user space notification of OOM
for cgroup memory controller. When a group is about to OOM,
a notification can help an external application re-adjust
memory limits across the system.

Keeping some memory reserved for handling OOM, this scheme could
be extended to handle global OOM conditions as well.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
