Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5PHWPge164014
	for <linux-mm@kvack.org>; Tue, 26 Jun 2007 03:32:25 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5PHYrVS103048
	for <linux-mm@kvack.org>; Tue, 26 Jun 2007 03:34:53 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5PHVK6l021025
	for <linux-mm@kvack.org>; Tue, 26 Jun 2007 03:31:21 +1000
Message-ID: <46808178.6010402@linux.vnet.ibm.com>
Date: Mon, 25 Jun 2007 23:01:12 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] mm-controller
References: <1182418364.21117.134.camel@twins> <467A5B1F.5080204@linux.vnet.ibm.com> <1182433855.21117.160.camel@twins> <467BFA47.4050802@linux.vnet.ibm.com> <1182788561.6174.70.camel@lappy>
In-Reply-To: <1182788561.6174.70.camel@lappy>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Pavel Emelianov <xemul@sw.ru>, Paul Menage <menage@google.com>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>, Roy Huang <royhuang9@gmail.com>, Aubrey Li <aubreylee@gmail.com>, riel@redhat.POK.IBM.COM
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Fri, 2007-06-22 at 22:05 +0530, Vaidyanathan Srinivasan wrote:
> 
>> Merging both limits will eliminate the issue, however we would need
>> individual limits for pagecache and RSS for better control.  There are
>> use cases for pagecache_limit alone without RSS_limit like the case of
>> database application using direct IO, backup applications and
>> streaming applications that does not make good use of pagecache.
> 
> I'm aware that some people want this. However we rejected adding a
> pagecache limit to the kernel proper on grounds that reclaim should do a
> better job.
> 
> And now we're sneaking it in the backdoor.
> 


We'll we are trying to provide a memory controller and page cache is a
part of memory. The page reclaimer does treat page cache separately.
Isn't this approach better than simply extending the vm_swappiness
to per container?


> If we're going to do this, get it in the kernel proper first.
> 

I'm open to this. There were several patches to do this. We can do
this by splitting the LRU list to mapped and unmapped pages or
by trying to balance the page cache by tracking it's usage.

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
