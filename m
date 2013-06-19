Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 8A5C06B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 10:17:15 -0400 (EDT)
Received: by mail-vb0-f54.google.com with SMTP id q12so3789191vbe.13
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 07:17:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130619140920.GA11843@cerebellum>
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1370291585-26102-4-git-send-email-sjenning@linux.vnet.ibm.com>
	<CAA_GA1eWFYDxp3gEdWzajVP4jMpmJbt=oWBZYqZEQjndU=s_Qg@mail.gmail.com>
	<20130619140920.GA11843@cerebellum>
Date: Wed, 19 Jun 2013 22:17:14 +0800
Message-ID: <CAA_GA1dm=tsFotB3mFemKEpk5arONfD6+LMkC-G6tBhBR5wAsg@mail.gmail.com>
Subject: Re: [PATCHv13 3/4] zswap: add to mm/
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Jun 19, 2013 at 10:09 PM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
> On Mon, Jun 17, 2013 at 02:20:05PM +0800, Bob Liu wrote:
>> Hi Seth,
>>
>> On Tue, Jun 4, 2013 at 4:33 AM, Seth Jennings
>> <sjenning@linux.vnet.ibm.com> wrote:
>> > zswap is a thin backend for frontswap that takes pages that are in the process
>> > of being swapped out and attempts to compress them and store them in a
>> > RAM-based memory pool.  This can result in a significant I/O reduction on the
>> > swap device and, in the case where decompressing from RAM is faster than
>> > reading from the swap device, can also improve workload performance.
>> >
>> > It also has support for evicting swap pages that are currently compressed in
>> > zswap to the swap device on an LRU(ish) basis. This functionality makes zswap a
>> > true cache in that, once the cache is full, the oldest pages can be moved out
>> > of zswap to the swap device so newer pages can be compressed and stored in
>> > zswap.
>> >
>> > This patch adds the zswap driver to mm/
>> >
>>
>> Do you have any more benchmark can share with me ? To figure out that
>> we can benefit from zswap.
>
> The two I've done or kernbench and SPECjbb.  I'm trying out the memtests

Thanks, I'll try to setup them.

> now.  I'd like to be able to explain the numbers you are seeing at least.
>
> Sorry for the delay.  I'll get back to you once I've figured out how
> to using mmtests and get some results/explanations.
>
> Also, how much physical RAM did this box have? I see 2G in the profile name
> but not sure if that is the workload size or the RAM size.  I seems that the

2G RAM size.

> test is overcommitted from the beginning as indicated by the swap activity.
> I know that the parallelio-memcachetest default profile only uses 80% of
> physical memory, so you have apparently made a change yes?
>

No, I just "cp configs/config-global-dhp__parallelio-memcachetest
config" and then run mmtests.sh with monitor.
I'm using mmtests version 0.10.

--
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
