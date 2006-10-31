Date: Tue, 31 Oct 2006 01:42:43 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [ckrm-tech] RFC: Memory Controller
Message-Id: <20061031014243.1153655b.akpm@osdl.org>
In-Reply-To: <45471510.4070407@in.ibm.com>
References: <20061030103356.GA16833@in.ibm.com>
	<4545D51A.1060808@in.ibm.com>
	<4546212B.4010603@openvz.org>
	<454638D2.7050306@in.ibm.com>
	<45463F70.1010303@in.ibm.com>
	<45470FEE.6040605@openvz.org>
	<45471510.4070407@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, vatsa@in.ibm.com, dev@openvz.org, sekharan@us.ibm.com, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, pj@sgi.com, matthltc@us.ibm.com, dipankar@in.ibm.com, rohitseth@google.com, menage@google.com, linux-mm@kvack.org, Vaidyanathan S <svaidy@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Oct 2006 14:49:12 +0530
Balbir Singh <balbir@in.ibm.com> wrote:

> The idea behind limiting the page cache is this
> 
> 1. Lets say one container fills up the page cache.
> 2. The other containers will not be able to allocate memory (even
> though they are within their limits) without the overhead of having
> to flush the page cache and freeing up occupied cache. The kernel
> will have to pageout() the dirty pages in the page cache.

There's a vast difference between clean pagecache and dirty pagecache in this
context.  It is terribly imprecise to use the term "pagecache".  And it would be
a poor implementation which failed to distinguish between clean pagecache and
dirty pagecache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
