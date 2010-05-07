Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AEC936B02AB
	for <linux-mm@kvack.org>; Fri,  7 May 2010 18:46:59 -0400 (EDT)
Received: by fxm7 with SMTP id 7so359374fxm.14
        for <linux-mm@kvack.org>; Fri, 07 May 2010 15:46:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100221030238.GA26511@hexapodia.org>
References: <20100216181312.GA9700@frostnet.net> <20100221030238.GA26511@hexapodia.org>
From: =?ISO-8859-1?Q?C=E9dric_Villemain?= <cedric.villemain.debian@gmail.com>
Date: Sat, 8 May 2010 00:46:37 +0200
Message-ID: <k2xe94e14cd1005071546i2806354dm55ad7ae89e46e5f5@mail.gmail.com>
Subject: Re: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andy Isaacson <adi@hexapodia.org>
Cc: Chris Frost <chris@frostnet.net>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, Andrew@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve VanDeBogart <vandebo-lkml@nerdbox.net>, linux-fsdevel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

2010/2/21 Andy Isaacson <adi@hexapodia.org>:
> On Tue, Feb 16, 2010 at 10:13:12AM -0800, Chris Frost wrote:
>> Add the fincore() system call. fincore() is mincore() for file descripto=
rs.
>>
>> The functionality of fincore() can be emulated with an mmap(), mincore()=
,
>> and munmap(), but this emulation requires more system calls and requires
>> page table modifications. fincore() can provide a significant performanc=
e
>> improvement for non-sequential in-core queries.
>
> In addition to being expensive, mmap/mincore/munmap perturb the VM's
> eviction algorithm -- a page is less likely to be evicted if it's
> mmapped when being considered for eviction.
>
> I frequently see this happen when using mincore(1) from
> http://bitbucket.org/radii/mincore/ -- "watch mincore -v *.big" while
> *.big are being sequentially read results in a significant number of
> pages remaining in-core, whereas if I only run mincore after the
> sequential read is complete, the large files will be nearly-completely
> out of core (except for the tail of the last file, of course).
>
> It's very interesting to watch
> % watch --interval=3D.5 mincore -v *
>
> while an IO-intensive process is happening, such as mke2fs on a
> filesystem image.
>
> So, I support the addition of fincore(2) and would use it if it were
> merged.

I wonder what the actual state is for this proposition?
I'd like to see fincore(2) added too...

>
> -andy
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
C=E9dric Villemain

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
