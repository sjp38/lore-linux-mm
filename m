Message-Id: <l03130322b745b6bd9598@[192.168.239.105]>
In-Reply-To: <3B1FED7C.4E483BCD@mandrakesoft.com>
References: <l0313031fb74590aea499@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 7 Jun 2001 23:59:02 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: [PATCH] VM tuning patch, take 2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> >>For comparison, what was the time taken by -j15 build before your patch?
>> >
>> >Plain 2.4.5 gives 6m20s, but uses 190Mb of swap to achieve that - nearly 3
>> >times what my patched version does.  I could try adding more swap (on a
>> >faster device) and see what make -j 20 does...
>>
>> On plain 2.4.5 and a 1Gb swapfile located on an Ultra160 10000rpm device,
>> make -j 20 took 7m20s, peaking at 370Mb swap usage.  With the extra
>> patches, it takes 6m30, peaking at 254Mb swap usage.  Looks like the new
>> patches have a greater positive impact the higher the VM load.  :)
>
>From your numbers I have seen no regressions/negative impact, so right
>on :)

OK, the patch is now uploaded at:

http://www.chromatix.uklinux.net/linux-patches/vm-update-2.patch

I'd like people to go over it to make sure I've not boo-booed in some
SMP-incompatible way, then the guys with the big machines and workloads can
have a play.  It incorporates many if not most of the individual
improvements posted here, as well as some additions of my own, so I
strongly reccommend applying to a virgin 2.4.5 tree.

Enjoy!


--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)

The key to knowledge is not to rely on people to teach you it.

GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
