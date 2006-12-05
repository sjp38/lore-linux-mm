Message-ID: <457595A5.3060008@shadowen.org>
Date: Tue, 05 Dec 2006 15:52:05 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
References: <20061130170746.GA11363@skynet.ie>	<20061130173129.4ebccaa2.akpm@osdl.org>	<Pine.LNX.4.64.0612010948320.32594@skynet.skynet.ie>	<20061201110103.08d0cf3d.akpm@osdl.org>	<20061204140747.GA21662@skynet.ie>	<20061204113051.4e90b249.akpm@osdl.org>	<Pine.LNX.4.64.0612041946460.26428@skynet.skynet.ie> <20061204143435.6ab587db.akpm@osdl.org>
In-Reply-To: <20061204143435.6ab587db.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, clameter@sgi.com, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 4 Dec 2006 20:34:29 +0000 (GMT)
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
>>> IOW: big-picture where-do-we-go-from-here stuff.
>>>
>> Start with lumpy reclaim,
> 
> I had lumpy-reclaim in my todo-queue but it seems to have gone away.  I
> think I need a lumpy-reclaim resend, please.

There was a clash with it against 2.6.19-r6-mm2, I've respun it and am 
just retesting it.  When thats done I'll drop it out to you.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
