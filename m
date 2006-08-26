Message-ID: <44F0C312.1050300@redhat.com>
Date: Sat, 26 Aug 2006 17:54:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] nfs: Enable swap over NFS
References: <20060825153709.24254.28118.sendpatchset@twins> <20060825153812.24254.9718.sendpatchset@twins> <20060826143622.GA5260@ucw.cz>
In-Reply-To: <20060826143622.GA5260@ucw.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:
> Hi!
> 
>> Now that NFS can handle swap cache pages, add a swapfile method to allow
>> swapping over NFS.
>>
>> NOTE: this dummy method is obviously not enough to make it safe.
>> A more complete version of the nfs_swapfile() function will be present
>> in the next VM deadlock avoidance patches.
>>
>> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> We probably do not want to enable functionality before it is safe...

OTOH, if we never enable this, what motivation do we have to
make it safe? :)

Scratching an itch works, so maybe we ought to create an itch?

-- 
What is important?  What you want to be true, or what is true?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
