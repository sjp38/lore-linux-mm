Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 9DAB96B00A0
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 05:16:53 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id qd12so6731542ieb.22
        for <linux-mm@kvack.org>; Mon, 16 Sep 2013 02:16:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130909164750.GC4701@variantweb.net>
References: <000601ceaac0$5be39f90$13aadeb0$%yang@samsung.com>
	<20130909164750.GC4701@variantweb.net>
Date: Mon, 16 Sep 2013 17:16:52 +0800
Message-ID: <CAL1ERfNmeMCyUGyjTX4_AV41E_iCJicBoz=w16iSOUp+YKYi8A@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] mm/zswap: use GFP_NOIO instead of GFP_KERNEL
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, minchan@kernel.org, bob.liu@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 10, 2013 at 12:47 AM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
> On Fri, Sep 06, 2013 at 01:16:45PM +0800, Weijie Yang wrote:
>> To avoid zswap store and reclaim functions called recursively,
>> use GFP_NOIO instead of GFP_KERNEL
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>
> I agree with Bob to some degree that GFP_NOIO is a broadsword here.
> Ideally, we'd like to continue allowing writeback of dirty file pages
> and the like.  However, I don't agree that a mutex is the way to do
> this.
>
> My first thought was to use the PF_MEMALLOC task flag, but it is already
> set for kswapd and any task doing direct reclaim.  A new task flag would
> work but I'm not sure how acceptable that would be.

as GFP_NOIO is controversial and not the most appropriate method,
I will keep GFP_KERNEL flag until we find a better way to resolve
this problem.

> In the meantime, this does do away with the possibility of very deep
> recursion between the store and reclaim paths.
>
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
