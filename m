Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 8825A6B006E
	for <linux-mm@kvack.org>; Sun,  9 Dec 2012 22:15:58 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id l22so2564897vbn.14
        for <linux-mm@kvack.org>; Sun, 09 Dec 2012 19:15:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <c8728036-07da-49ce-b4cb-c3d800790b53@default>
References: <c8728036-07da-49ce-b4cb-c3d800790b53@default>
Date: Mon, 10 Dec 2012 11:15:57 +0800
Message-ID: <CAA_GA1eBR6=vasnoSDYZK9qvYQtzVS9q2CHC3M-qeVRRp1dhPg@mail.gmail.com>
Subject: Re: zram /proc/swaps accounting weirdness
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org

Hi Dan,

On Sat, Dec 8, 2012 at 7:57 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> While playing around with zcache+zram (see separate thread),
> I was watching stats with "watch -d".
>
> It appears from the code that /sys/block/num_writes only
> increases, never decreases.  In my test, num_writes got up
> to 1863.  /sys/block/disksize is 104857600.
>
> I have two swap disks, one zram (pri=60), one real (pri=-1),
> and as a I watched /proc/swaps, the "Used" field grew rapidly
> and reached the Size (102396k) of the zram swap, and then
> the second swap disk (a physical disk partition) started being
> used.  Then for awhile, the Used field for both swap devices
> was changing (up and down).
>
> Can you explain how this could happen if num_writes never
> exceeded 1863?  This may be harmless in the case where
> the only swap on the system is zram; or may indicate a bug
> somewhere?
>

Sorry, I didn't get your idea here.
In my opinion, num_writes is the count of request but not the size.
I think the total size should be the sum of bio->bi_size,
so if num_writes is 1863 the actual size may also exceed 102396k.

> It looks like num_writes is counting bio's not pages...
> which would imply the bio's are potentially quite large
> (and I'll guess they are of size SWAPFILE_CLUSTER which is
> defined to be 256).  Do large clusters make sense with zram?
>
> Late on a Friday so sorry if I am incomprehensible...
>
> P.S. The corresponding stat for zcache indicates that
> it failed 8852 stores, so I would have expected zram
> to deal with no more than 8852 compressions.
>

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
