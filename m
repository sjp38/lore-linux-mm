Date: Fri, 18 Jan 2008 17:17:31 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 2/2] Allow any x86 sub-architecture type to set
	CONFIG_NUMA
Message-ID: <20080118161731.GB5850@elte.hu>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <20080118153609.12646.97784.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080118153609.12646.97784.sendpatchset@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

* Mel Gorman <mel@csn.ul.ie> wrote:

> While there are a limited number of x86 sub-architecture types that 
> can really support NUMA, there is nothing stopping other machines 
> booting that type of kernel. The fact that X86_GENERICARCH can set 
> NUMA currently is an indicator of that. This restriction only limits 
> potential testing coverage. This patch allows any sub-architecture to 
> set CONFIG_NUMA if they wish.

thanks, applied.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
