Date: Wed, 31 Oct 2007 10:03:07 -0400 (EDT)
From: Byron Stanoszek <bstanoszek@comtime.com>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
In-Reply-To: <200710311504.24016.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710310952280.2205@winds.org>
References: <20071030160401.296770000@chello.nl> <200710311426.33223.nickpiggin@yahoo.com.au>
 <20071030.213753.126064697.davem@davemloft.net> <200710311504.24016.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: David Miller <davem@davemloft.net>, a.p.zijlstra@chello.nl, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 31 Oct 2007, Nick Piggin wrote:

> On Wednesday 31 October 2007 15:37, David Miller wrote:
>> From: Nick Piggin <nickpiggin@yahoo.com.au>
>> Date: Wed, 31 Oct 2007 14:26:32 +1100
>>
>>> Is it really worth all the added complexity of making swap
>>> over NFS files work, given that you could use a network block
>>> device instead?
>>
>> Don't be misled.  Swapping over NFS is just a scarecrow for the
>> seemingly real impetus behind these changes which is network storage
>> stuff like iSCSI.
>
> Oh, I'm OK with the network reserves stuff (not the actual patch,
> which I'm not really qualified to review, but at least the idea
> of it...).
>
> And also I'm not as such against the idea of swap over network.
>
> However, specifically the change to make swapfiles work through
> the filesystem layer (ATM it goes straight to the block layer,
> modulo some initialisation stuff which uses block filesystem-
> specific calls).
>
> I mean, I assume that anybody trying to swap over network *today*
> has to be using a network block device anyway, so the idea of
> just being able to transparently improve that case seems better
> than adding new complexities for seemingly not much gain.

I have some embedded diskless devices that have 16 MB of RAM and >500MB of
swap. Its root fs and swap device are both done over NBD because NFS is too
expensive in 16MB of RAM. Any memory contention (i.e needing memory to swap
memory over the network), however infrequent, causes the system to freeze when
about 50 MB of VM is used up. I would love to see some work done in this area.

  -Byron

--
Byron Stanoszek                         Ph: (330) 644-3059
Systems Programmer                      Fax: (330) 644-8110
Commercial Timesharing Inc.             Email: byron@comtime.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
