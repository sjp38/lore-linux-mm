Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EDEBA6B0218
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 13:05:20 -0400 (EDT)
Message-ID: <4BA10B66.1020705@redhat.com>
Date: Wed, 17 Mar 2010 19:03:34 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9F4CBD.3020805@redhat.com> <20100317152452.GZ31148@arachsys.com> <4BA101C5.9040406@redhat.com> <4BA105FE.2000607@redhat.com> <20100317164752.GA31884@arachsys.com> <4BA1090E.9090502@redhat.com> <20100317165854.GC29548@lst.de>
In-Reply-To: <20100317165854.GC29548@lst.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: Chris Webb <chris@arachsys.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kevin Wolf <kwolf@redhat.com>
List-ID: <linux-mm.kvack.org>

On 03/17/2010 06:58 PM, Christoph Hellwig wrote:
> On Wed, Mar 17, 2010 at 06:53:34PM +0200, Avi Kivity wrote:
>    
>> Meanwhile I looked at the code, and it looks bad.  There is an
>> IO_CMD_FDSYNC, but it isn't tagged, so we have to drain the queue before
>> issuing it.  In any case, qemu doesn't use it as far as I could tell,
>> and even if it did, device-matter doesn't implement the needed
>> ->aio_fsync() operation.
>>      
> No one implements it, and all surrounding code is dead wood.  It would
> require us to do asynchronous pagecache operations, which involve
> major surgery of the VM code.  Patches to do this were rejected multiple
> times.
>    

Pity.  What about the O_DIRECT aio case?  It's ridiculous that you can 
submit async write requests but have to wait synchronously for them to 
actually hit the disk if you have a write cache.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
