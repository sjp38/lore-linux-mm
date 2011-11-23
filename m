Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 172D76B009F
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 16:31:45 -0500 (EST)
Received: by dye36 with SMTP id 36so176010dye.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 13:31:42 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: use of alloc_bootmem for a PCI-e device
References: <9AF7658D-FEDB-479A-8D4F-A54264363CB4@gmail.com>
 <op.v5ey7hv93l0zgt@mpn-glaptop>
 <DEF7AFA8-9119-4FD7-915E-FB8572F06F02@gmail.com>
Date: Wed, 23 Nov 2011 22:31:40 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v5e4q2ug3l0zgt@mpn-glaptop>
In-Reply-To: <DEF7AFA8-9119-4FD7-915E-FB8572F06F02@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Francois Dagenais <jeff.dagenais@gmail.com>
Cc: linux-mm@kvack.org

> On Nov 23, 2011, at 14:31, Michal Nazarewicz wrote:
>> One trick that you might try to use (even though it's a bit hackish) =
is to
>> pass ram=3D### on Linux command line where the number passed is actua=
l memory
>> minus size of the buffer you need.  Other then that, you might take a=
 look
>> at CMA (CMAv17 it was sent last week or so to linux-mm) which in one =
of the
>> initialisation steps needs to grab memory regions.

On Wed, 23 Nov 2011 22:21:15 +0100, Jean-Francois Dagenais <jeff.dagenai=
s@gmail.com> wrote:
> Looks like it can do what I want. Are there any mainline merge plans?

There are plans...  Execution is uncertain. ;)

> Unless I am mistaken, because of SWIOTLB, only x86_32 is supported, co=
rrect?
>
> Since I want to allocate the buffer once at startup, then keep it unti=
l shutdown,
> can you suggest a simpler, less flexible alternative?

Oh no, I wouldn't recommend using the full CMA for your purpose, but no =
matter
there is a piece of code that does what you need.  Marek has added suppo=
rt for
Intel so it should work for you as well, even though I have had a chance=
 to
run that piece yet.

You are interested in parts of patch 8[1] (namely dma_declare_contiguous=
()
function) and the last hunk of patch 9[2] (namely the part where
dma_contiguous_reserve() is called).

[1] http://article.gmane.org/gmane.linux.kernel.mm/70321
[2] http://article.gmane.org/gmane.linux.kernel.mm/70318

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
