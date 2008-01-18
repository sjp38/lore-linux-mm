Date: Fri, 18 Jan 2008 17:17:19 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] Do not require CONFIG_HIGHMEM64G to set
	CONFIG_NUMA on x86
Message-ID: <20080118161719.GA5850@elte.hu>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <20080118153549.12646.1915.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080118153549.12646.1915.sendpatchset@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, apw@shadowen.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Mel Gorman <mel@csn.ul.ie> wrote:

> There is nothing inherent in HIGHMEM64G required for CONFIG_NUMA to 
> work. It just limits potential testing coverage so remove the 
> limitation.

thanks Mel, applied. Great change - this will trigger NUMA related build 
(and boot) failures must faster in randconfig testing.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
