Message-ID: <46646A33.6090107@google.com>
Date: Mon, 04 Jun 2007 12:38:27 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/7] cpuset write dirty map
References: <465FB6CF.4090801@google.com> <Pine.LNX.4.64.0706041138410.24412@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706041138410.24412@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@google.com>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 31 May 2007, Ethan Solomita wrote:
> 
>> The dirty map is only cleared (or freed) when the inode is cleared.
>> At that point no pages are attached to the inode anymore and therefore it can
>> be done without any locking. The dirty map therefore records all nodes that
>> have been used for dirty pages by that inode until the inode is no longer
>> used.
>>
>> Originally by Christoph Lameter <clameter@sgi.com>
> 
> You should preserve my Signed-off-by: since I wrote most of this. Is there 
> a changelog?
> 

	I wasn't sure of the etiquette -- I'd thought that by saying you had
signed it off that meant you were accepting my modifications, and didn't
want to presume. But I will change it if you like. No slight intended.

	Unfortunately I don't have a changelog, and since I've since forward
ported the changes it would be hard to produce. If you want to review it
you should probably review it all, because the forward porting may have
introduced issues.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
