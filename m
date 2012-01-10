Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 87DF06B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 07:49:01 -0500 (EST)
Received: by eeke53 with SMTP id e53so238415eek.14
        for <linux-mm@kvack.org>; Tue, 10 Jan 2012 04:48:59 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH v6 7/8] mm: only IPI CPUs to drain local pages if they
 exist
References: <1326040026-7285-8-git-send-email-gilad@benyossef.com>
 <alpine.DEB.2.00.1201091034390.31395@router.home>
 <op.v7tsxgu33l0zgt@mpn-glaptop>
 <CAOtvUMcJgnGf+RbF6J5zPxi3x4sCt7qoWe+Xd6C8GOhJV=xhqQ@mail.gmail.com>
Date: Tue, 10 Jan 2012 13:48:56 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v7vcjum63l0zgt@mpn-glaptop>
In-Reply-To: <CAOtvUMcJgnGf+RbF6J5zPxi3x4sCt7qoWe+Xd6C8GOhJV=xhqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Chris
 Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander
 Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

> 2012/1/9 Michal Nazarewicz <mina86@mina86.com>:
>> This is initialised in setup_per_cpu_pageset() so it needs to be file=

>> scoped.

On Tue, 10 Jan 2012 13:43:21 +0100, Gilad Ben-Yossef <gilad@benyossef.co=
m> wrote:
> Yes. The cpumask_var_t abstraction is convenient and all but it does
> make the allocation very non obvious when it does not happen in
> proximity to the variable use - it doesn't *look* like a pointer.

You can say that about any file scoped variable that needs non-const
initialisation, not only pointers.

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
