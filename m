Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFE8900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 14:11:59 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p5MIBrq0028342
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:11:53 -0700
Received: from qwi4 (qwi4.prod.google.com [10.241.195.4])
	by hpaq6.eem.corp.google.com with ESMTP id p5MI7Yjo016577
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:11:52 -0700
Received: by qwi4 with SMTP id 4so587477qwi.29
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:11:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110622110910.c8e11eb7.rdunlap@xenotime.net>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
	<20110622110034.89ee399c.akpm@linux-foundation.org>
	<20110622110910.c8e11eb7.rdunlap@xenotime.net>
Date: Wed, 22 Jun 2011 11:11:51 -0700
Message-ID: <BANLkTim=N=8G+Q9HJ6BaMO8L3oZouanxvtsf99fVxYGquTewDg@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Nancy Yuen <yuenn@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, Michael Ditto <mditto@google.com>

I haven't had time to submit the patches, though it's on my todo list.

----------
Nancy



On Wed, Jun 22, 2011 at 11:09, Randy Dunlap <rdunlap@xenotime.net> wrote:
> On Wed, 22 Jun 2011 11:00:34 -0700 Andrew Morton wrote:
>
>> On Wed, 22 Jun 2011 13:18:51 +0200 Stefan Assmann <sassmann@kpanic.de> w=
rote:
>>
>> > Following the RFC for the BadRAM feature here's the updated version wi=
th
>> > spelling fixes, thanks go to Randy Dunlap. Also the code is now less v=
erbose,
>> > as requested by Andi Kleen.
>> > v2 with even more spelling fixes suggested by Randy.
>> > Patches are against vanilla 2.6.39.
>> >
>> > The idea is to allow the user to specify RAM addresses that shouldn't =
be
>> > touched by the OS, because they are broken in some way. Not all machin=
es have
>> > hardware support for hwpoison, ECC RAM, etc, so here's a solution that=
 allows to
>> > use bitmasks to mask address patterns with the new "badram" kernel com=
mand line
>> > parameter.
>> > Memtest86 has an option to generate these patterns since v2.3 so the o=
nly thing
>> > for the user to do should be:
>> > - run Memtest86
>> > - note down the pattern
>> > - add badram=3D<pattern> to the kernel command line
>> >
>> > The concerning pages are then marked with the hwpoison flag and thus w=
on't be
>> > used by the memory managment system.
>>
>> The google kernel has a similar capability. =A0I asked Nancy to comment
>> on these patches and she said:
>>
>> : One, the bad addresses are passed via the kernel command line, which
>> : has a limited length. =A0It's okay if the addresses can be fit into a
>> : pattern, but that's not necessarily the case in the google kernel. =A0=
And
>> : even with patterns, the limit on the command line length limits the
>> : number of patterns that user can specify. =A0Instead we use lilo to pa=
ss
>> : a file containing the bad pages in e820 format to the kernel.
>> :
>> : Second, the BadRAM patch expands the address patterns from the command
>> : line into individual entries in the kernel's e820 table. =A0The e820
>> : table is a fixed buffer that supports a very small, hard coded number
>> : of entries (128). =A0We require a much larger number of entries (on
>> : the order of a few thousand), so much of the google kernel patch deals
>> : with expanding the e820 table. Also, with the BadRAM patch, entries
>> : that don't fit in the table are silently dropped and this isn't
>> : appropriate for us.
>> :
>> : Another caveat of mapping out too much bad memory in general. =A0If to=
o
>> : much memory is removed from low memory, a system may not boot. =A0We
>> : solve this by generating good maps. =A0Our userspace tools do not map =
out
>> : memory below a certain limit, and it verifies against a system's iomap
>> : that only addresses from memory is mapped out.
>>
>> I have a couple of thoughts here:
>>
>> - If this patchset is merged and a major user such as google is
>> =A0 unable to use it and has to continue to carry a separate patch then
>> =A0 that's a regrettable situation for the upstream kernel.
>>
>> - Google's is, afaik, the largest use case we know of: zillions of
>> =A0 machines for a number of years. =A0And this real-world experience te=
lls
>> =A0 us that the badram patchset has shortcomings. =A0Shortcomings which =
we
>> =A0 can expect other users to experience.
>>
>> So. =A0What are your thoughts on these issues?
>
>
> Good comments, so where is google's patch submittal?
>
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code =
***
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
