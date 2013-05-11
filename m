Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 519086B0032
	for <linux-mm@kvack.org>; Fri, 10 May 2013 21:19:21 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id z12so4477646wgg.11
        for <linux-mm@kvack.org>; Fri, 10 May 2013 18:19:19 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <20130510084413.GA2683@blaptop>
References: <1368056517-31065-1-git-send-email-minchan@kernel.org>
 <20130509201540.GB5273@localhost.localdomain> <20130510084413.GA2683@blaptop>
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Date: Fri, 10 May 2013 21:18:59 -0400
Message-ID: <CAPbh3rsVnvEmH+sRoRYjGi3DERMkzFPmOn=a_Gt0uAMnLLmZJg@mail.gmail.com>
Subject: Re: [PATCH v3] mm: remove compressed copy from zram in-memory
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Shaohua Li <shli@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>

On Fri, May 10, 2013 at 4:44 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hi Konrad,
>
> On Thu, May 09, 2013 at 04:15:42PM -0400, Konrad Rzeszutek Wilk wrote:
>> On Thu, May 09, 2013 at 08:41:57AM +0900, Minchan Kim wrote:
>>
>> Hey Michan,
>         ^-n
>
> It's a only thing I can know better than other native speakers. :)

I keep on misspelling your name. I am really sorry about that.

>
>
>> Just a couple of syntax corrections. The code comment could also
>> benefit from this.
>>
>> Otherwise it looks OK to me.
>>
>> > Swap subsystem does lazy swap slot free with expecting the page
>>                      ^-a                       ^- the expectation that
>> > would be swapped out again so we can avoid unnecessary write.
>>                                 ^--that it
>> >
>> > But the problem in in-memory swap(ex, zram) is that it consumes
>>                   ^^-with
>> > memory space until vm_swap_full(ie, used half of all of swap device)
>> > condition meet. It could be bad if we use multiple swap device,
>>            ^- 'is'   ^^^^^ - 'would'                       ^^^^^-devices
>> > small in-memory swap and big storage swap or in-memory swap alone.
>>                       ^-,                   ^-,
>> >
>> > This patch makes swap subsystem free swap slot as soon as swap-read
>> > is completed and make the swapcache page dirty so the page should
>>                        ^-makes                      ^-'that the'
>> > be written out the swap device to reclaim it.
>> > It means we never lose it.
>> >
>> > I tested this patch with kernel compile workload.
>>                           ^-a
>
> Thanks for the correct whole sentence!
> But Andrew alreay correted it with his style.

<nods> I saw his email a couple of hours ago.

> Although he was done, I'm giving a million thanks to you.
> Surely, Thanks Andrew, too.
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
