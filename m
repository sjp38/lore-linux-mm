Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5MGvNwh279836
	for <linux-mm@kvack.org>; Sat, 23 Jun 2007 02:57:23 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5MGd2HS144868
	for <linux-mm@kvack.org>; Sat, 23 Jun 2007 02:39:03 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5MGZTqN018127
	for <linux-mm@kvack.org>; Sat, 23 Jun 2007 02:35:30 +1000
Message-ID: <467BFA47.4050802@linux.vnet.ibm.com>
Date: Fri, 22 Jun 2007 22:05:19 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm-controller
References: <1182418364.21117.134.camel@twins> <467A5B1F.5080204@linux.vnet.ibm.com> <1182433855.21117.160.camel@twins>
In-Reply-To: <1182433855.21117.160.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: balbir@linux.vnet.ibm.com, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Pavel Emelianov <xemul@sw.ru>, Paul Menage <menage@google.com>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>, Roy Huang <royhuang9@gmail.com>, Aubrey Li <aubreylee@gmail.com>
List-ID: <linux-mm.kvack.org>


Peter Zijlstra wrote:
> On Thu, 2007-06-21 at 16:33 +0530, Balbir Singh wrote:
>> Peter Zijlstra wrote:
[snip]

> Not quite sure on 2, from reading the pagecache controller, I got the
> impression that enforcing both limits got you into trouble. Merging the
> limits would rid us of that issue, no?
> 

Hi Peter,

Setting both limits in pagecache controller (v4) will work correct in
principle.  What I intended in the comment is performance issues and
wrong type of page being reclaimed.  We are working on the issues and
will fix them in future versions.  You can set any combination of
limits and the reclaim will work to keep the page utilization below
limits.

When RSS limit is hit, ANON pages are pushed to swapcache.  We would
need to limit swapcache (using pagecache_limit) to force a write out
to disk.

Merging both limits will eliminate the issue, however we would need
individual limits for pagecache and RSS for better control.  There are
use cases for pagecache_limit alone without RSS_limit like the case of
database application using direct IO, backup applications and
streaming applications that does not make good use of pagecache.

Thank you for the review and new design proposal.

--Vaidy

[snip]


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
