Subject: Re: 2.5.69-mm8
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <9790000.1053632393@[10.10.2.4]>
References: <20030522021652.6601ed2b.akpm@digeo.com>
	 <1053629620.596.1.camel@teapot.felipe-alfaro.com>
	 <1053631843.2648.3248.camel@plars>  <9790000.1053632393@[10.10.2.4]>
Content-Type: text/plain
Message-Id: <1053637395.22758.6.camel@nighthawk>
Mime-Version: 1.0
Date: 22 May 2003 14:03:15 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Paul Larson <plars@linuxtestproject.org>, Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>, Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2003-05-22 at 12:39, Martin J. Bligh wrote:
> Also seems to hang rather easily. When it gets into that state, it's difficult
> to tell what works and what doesn't ... I can login over serial, but not 
> start new ssh's and "ps -ef" hangs for ever. I'll try to get some more
> information, and assemble a less-totally-crap bug report.

Give sysrq 't' a shot

echo t > /proc/sysrq-trigger

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
