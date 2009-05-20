Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4BB7B6B009F
	for <linux-mm@kvack.org>; Wed, 20 May 2009 15:18:09 -0400 (EDT)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Subject: RE: [PATCH] mm/slub.c: Use print_hex_dump and remove unnecessary cast
Date: Wed, 20 May 2009 15:18:22 -0400
Message-ID: <BD79186B4FD85F4B8E60E381CAEE1909017FEF96@mi8nycmail19.Mi8.com>
In-Reply-To: <1242844966.22786.52.camel@Joe-Laptop.home>
References: <1242840314-25635-1-git-send-email-joe@perches.com> <alpine.DEB.1.10.0905201420050.17511@qirst.com> <1242844966.22786.52.camel@Joe-Laptop.home>
From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>, Christoph Lameter <cl@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, David Rientjes <rientjes@google.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

On Wednesday, May 20, 2009 11:43 AM, Joe Perches wrote:
> On Wed, 2009-05-20 at 14:23 -0400, Christoph Lameter wrote:
>> This was discussed before.
>> http://lkml.indiana.edu/hypermail/linux/kernel/0705.3/2671.html
>
> You've got a good memory.
>
>> Was hexdump changed?
>
> It seems not.
>
>> How does the output look after this change?
>>
>> From reading the code, the last column is unaligned.
>
> I did submit a patch to fix hexdump once.
> http://lkml.org/lkml/2007/12/6/304

>From what I can tell the current code does properly align the
ascii output.

I just chopped the necessary functions out of the kernel and
created a test program.  If I pass the string:

"This is a sample buffer"

I get the following output:

prefix_type =3D DUMP_PREFIX_NONE

<7>buffer: 54 68 69 73 20 69 73 20 61 20 73 61 6d 70 6c 65  This is a =
sample
<7>buffer: 20 62 75 66 66 65 72                              buffer

prefix_type =3D DUMP_PREFIX_ADDRESS

<7>buffer: 0x804a008: 54 68 69 73 20 69 73 20 61 20 73 61 6d 70 6c 65  =
This is a sample
<7>buffer: 0x804a018: 20 62 75 66 66 65 72                              =
buffer

prefix_type =3D DUMP_PREFIX_OFFSET

<7>buffer: 00000000: 54 68 69 73 20 69 73 20 61 20 73 61 6d 70 6c 65  =
This is a sample
<7>buffer: 00000010: 20 62 75 66 66 65 72                              =
buffer

Regards,
Hartley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
