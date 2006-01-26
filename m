Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0QM35V7004249
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 17:03:05 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0QM5KUO137516
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 15:05:20 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0QM333A000352
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 15:03:03 -0700
Message-ID: <43D94714.2030506@us.ibm.com>
Date: Thu, 26 Jan 2006 14:03:00 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 6/9] mempool - Update kzalloc mempool users
References: <20060125161321.647368000@localhost.localdomain>	 <1138218014.2092.6.camel@localhost.localdomain> <84144f020601252330k61789482m25a4316c2c254065@mail.gmail.com>
In-Reply-To: <84144f020601252330k61789482m25a4316c2c254065@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Hi,
> 
> On 1/25/06, Matthew Dobson <colpatch@us.ibm.com> wrote:
> 
>>plain text document attachment (critical_mempools)
>>Fixup existing mempool users to use the new mempool API, part 3.
>>
>>This mempool users which are basically just wrappers around kzalloc().  To do
>>this we create a new function, kzalloc_node() and change all the old mempool
>>allocators which were calling kzalloc() to now call kzalloc_node().
> 
> 
> The slab bits look good to me. You might have some rediffing to do
> because -mm has quite a bit of slab patches in it.
> 
> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
> 
>                                Pekka

Good to hear.  I expect there to be plenty of differences.  Some pieces of
this are ready to be pushed now, but most of it is still very much in
planning/design stage.  My hopes (which I probably should have made more
clear in the introductory email) are just to get feedback on the general
approach to the problem that I'm pursuing.

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
