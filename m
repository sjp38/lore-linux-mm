Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 963636B0033
	for <linux-mm@kvack.org>; Wed, 15 May 2013 16:46:49 -0400 (EDT)
In-Reply-To: <20130515200942.GA17724@cerebellum>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com> <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com> <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default> <20130514163541.GC4024@medulla> <f0272a06-141a-4d33-9976-ee99467f3aa2@default> <20130514225501.GA11956@cerebellum> <4d74f5db-11c1-4f58-97f4-8d96bbe601ac@default> <20130515185506.GA23342@phenom.dumpdata.com> <20130515200942.GA17724@cerebellum>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [PATCHv11 3/4] zswap: add to mm/
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Wed, 15 May 2013 16:45:36 -0400
Message-ID: <d1bf29e8-ffba-454c-95cd-bdef572f7c62@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:

>On Wed, May 15, 2013 a=
t 02:55:06PM -0400, Konrad Rzeszutek Wilk wrote:
>> > Sorry, but I don't th=
ink that's appropriate for a patch in the MM
>subsystem.
>> 
>> I am headin=
g to the airport shortly so this email is a bit hastily
>typed.
>> 
>> Perh=
aps a compromise can be reached where this code is merged as a
>driver
>> n=
ot a core mm component. There is a high bar to be in the MM - it has
>to
>>=
 work with many many different configurations. 
>> 
>> And drivers don't ha=
ve such a high bar. They just need to work on a
>specific
>> issue and that=
 is it. If zswap ended up in say, drivers/mm that would
>make
>> it more pa=
lpable I think.
>> 
>> Thoughts?
>
>zswap, the writeback code particularly,=
 depends on a number of
>non-exported
>kernel symbols, namely:
>
>swapcache=
_free
>__swap_writepage
>__add_to_swap_cache
>swapcache_prepare
>swapper_sp=
aces
>
>So it can't currently be built as a module and I'm not sure what th=
e MM
>folks would think about exporting them and making them part of the
>K=
ABI.
>
>Seth

Could those calls go through front swap? Meaning put the code=
 that uses these calls in there?
-- 
Sent from my Android phone. Please exc=
use my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
