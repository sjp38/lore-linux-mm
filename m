Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4216B0047
	for <linux-mm@kvack.org>; Sat,  2 Oct 2010 04:50:06 -0400 (EDT)
Message-ID: <4CA6F23B.5030209@kernel.org>
Date: Sat, 02 Oct 2010 11:50:03 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [Slub cleanup5 0/3] SLUB: Cleanups V5
References: <20100928131025.319846721@linux.com>
In-Reply-To: <20100928131025.319846721@linux.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On 28.9.2010 16.10, Christoph Lameter wrote:
> A couple of more cleanups (patches against Pekka's tree for next rebased to todays upstream)
>
> 1 Avoid #ifdefs by making data structures similar under SMP and NUMA
>
> 2 Avoid ? : by passing the redzone markers directly to the functions checking objects
>
> 3 Extract common code for removal of pages from partial list into a single function

The series has been applied. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
