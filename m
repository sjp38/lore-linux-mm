Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 543CD6B005A
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 03:42:45 -0500 (EST)
References: <1327310360.96918.YahooMailNeo@web162003.mail.bf1.yahoo.com> <1327313719.76517.YahooMailNeo@web162002.mail.bf1.yahoo.com> <alpine.LSU.2.00.1201231125200.1677@eggly.anvils> <1327468926.52380.YahooMailNeo@web162002.mail.bf1.yahoo.com> <alpine.LSU.2.00.1201251623340.2141@eggly.anvils>
Message-ID: <1327912964.12941.YahooMailNeo@web162006.mail.bf1.yahoo.com>
Date: Mon, 30 Jan 2012 00:42:44 -0800 (PST)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: [Help] : RSS/PSS showing 0 during smaps for Xorg
In-Reply-To: <alpine.LSU.2.00.1201251623340.2141@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Dear Hugh Dickins,=0A=A0=0AThank you very much for your reply.=0A=A0=0A>If =
these are ordinary pages with struct pages, then you could probably=0A>use =
a loop of vm_insert_page()s to insert them at mmap time, or a fault=0A>rout=
ine to insert them on fault.=A0 But as I said, I don't know if this=0A>memo=
ry is part of the ordinary page pool or not.=0A=A0=0AYou suggestion about u=
sing vm_insert_page() instead of remap_pfn_range worked for me and I got th=
e Rss/Pss information for my driver.=0ABut still there is one problem relat=
ed to page fault. =0AIf I remove remap_pfn_range then I get a page fault in=
 the beginning. =0AI tried to use the same vm_insert_page() during page_fau=
lt_handler for each vmf->virtual_address but it did not work.=0ASo for time=
 being I remove the page fault handler from my vm_operations.=0ABut with th=
ese my menu screen(LCD screen) is not behaving properly (I get colorful lin=
es on my LCD).=0ASo I need to handle the page fault properly.=0A=A0=0ABut I=
 am not sure what is that I need to do inside page fault handler. Do you ha=
ve any example or references or suggestions?=0A=A0=0A=A0=0A>Really, the que=
stion has to be, why do you need to see non-0s there?=0AI want Rss/Pss valu=
e to account for how much video memory is used by the driver for the menu-s=
creen,Xorg processes.=0A=A0=0A=A0=0A=A0=0AThanks,=0APintu=0A=A0=0A=0A>_____=
___________________________=0A>From: Hugh Dickins <hughd@google.com>=0A>To:=
 PINTU KUMAR <pintu_agarwal@yahoo.com> =0A>Cc: "linux-kernel@vger.kernel.or=
g" <linux-kernel@vger.kernel.org>; "linux-mm@kvack.org" <linux-mm@kvack.org=
> =0A>Sent: Thursday, 26 January 2012 6:29 AM=0A>Subject: Re: [Help] : RSS/=
PSS showing 0 during smaps for Xorg=0A>=0A>On Tue, 24 Jan 2012, PINTU KUMAR=
 wrote:=0A>> =A0=0A>> Is there a way to convert our mapped pages to a norma=
l pages. I tried pfn_to_page() but no effect.=0A>> I mean the page is consi=
dered normal only if it is associated with "struct page" right???=0A>> Is i=
s possible to convert these pages to a normal struct pages so that we can g=
et the Rss/Pss value??=0A>=0A>I don't understand why you are so anxious to =
see non-0 numbers there.=0A>=0A>I don't know if the pages you are mapping w=
ith remap_pfn_range() are=0A>ordinary pages in normal memory, and so alread=
y have struct pages, or not.=0A>=0A>> =A0=0A>> Also, the VM_PFNMAP is being=
 set for all dirvers during remap_pfn_range and stills shows Rss/Pss for ot=
her drivers.=0A>=0A>I'm surprised.=A0 It is possible to set up a private-wr=
itable VM_PFNMAP area,=0A>which can then contain ordinary private copies of=
 the underlying pages,=0A>and these copies will count to Rss.=A0 But I thou=
ght that was very unusual.=0A>=0A>You don't mention which drivers these are=
 that use remap_pfn_range yet=0A>show Rss (and I don't particularly want to=
 spend time researching them).=0A>=0A>I can see three or four places in dri=
vers/ where VM_PFNMAP is set,=0A>perhaps without going through remap_pfn_ra=
nge(): that seems prone=0A>to error, I wouldn't recommend going that route.=
=0A>=0A>> Then why it is not shown for our driver?=0A>> How to avoid remap_=
pfn_range to not to set VM_PFNMAP for our driver?=0A>=0A>If these are ordin=
ary pages with struct pages, then you could probably=0A>use a loop of vm_in=
sert_page()s to insert them at mmap time, or a fault=0A>routine to insert t=
hem on fault.=A0 But as I said, I don't know if this=0A>memory is part of t=
he ordinary page pool or not.=0A>=0A>Really, the question has to be, why do=
 you need to see non-0s there?=0A>=0A>Hugh=0A>=0A>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
