Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9B0E6B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 18:12:06 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id r5so3098142qkb.22
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 15:12:06 -0800 (PST)
Received: from mta01.ornl.gov (mta01.ornl.gov. [128.219.177.137])
        by mx.google.com with ESMTPS id e9si3135643qkh.274.2018.02.28.15.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 15:12:05 -0800 (PST)
From: "Atchley, Scott" <atchleyes@ornl.gov>
Subject: Re: [OMPI devel] [PATCH v5 0/4] vm: add a syscall to map a process
 memory into a pipe
Date: Wed, 28 Feb 2018 23:12:03 +0000
Message-ID: <B748ED06-77CC-47F6-AA5C-0D9E2AD1BDB2@ornl.gov>
References: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180220164406.3ec34509376f16841dc66e34@linux-foundation.org>
 <3122ec5a-7f73-f6b4-33ea-8c10ef32e5b0@virtuozzo.com>
 <20180227021818.GA31386@altlinux.org>
 <627ac4f8-a52d-0582-0c9e-e70ea667fa7e@virtuozzo.com>
In-Reply-To: <627ac4f8-a52d-0582-0c9e-e70ea667fa7e@virtuozzo.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <37B81FBCB154B54D891DDE89E76BC0D1@ornl.gov>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Open MPI Developers <devel@lists.open-mpi.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, "criu@openvz.org" <criu@openvz.org>, "gdb@sourceware.org" <gdb@sourceware.org>, "rr-dev@mozilla.org" <rr-dev@mozilla.org>, Arnd Bergmann <arnd@arndb.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>

> On Feb 28, 2018, at 2:12 AM, Pavel Emelyanov <xemul@virtuozzo.com> wrote:
>=20
> On 02/27/2018 05:18 AM, Dmitry V. Levin wrote:
>> On Mon, Feb 26, 2018 at 12:02:25PM +0300, Pavel Emelyanov wrote:
>>> On 02/21/2018 03:44 AM, Andrew Morton wrote:
>>>> On Tue,  9 Jan 2018 08:30:49 +0200 Mike Rapoport <rppt@linux.vnet.ibm.=
com> wrote:
>>>>=20
>>>>> This patches introduces new process_vmsplice system call that combine=
s
>>>>> functionality of process_vm_read and vmsplice.
>>>>=20
>>>> All seems fairly strightforward.  The big question is: do we know that
>>>> people will actually use this, and get sufficient value from it to
>>>> justify its addition?
>>>=20
>>> Yes, that's what bothers us a lot too :) I've tried to start with findi=
ng out if anyone=20
>>> used the sys_read/write_process_vm() calls, but failed :( Does anybody =
know how popular
>>> these syscalls are?
>>=20
>> Well, process_vm_readv itself is quite popular, it's used by debuggers n=
owadays,
>> see e.g.
>> $ strace -qq -esignal=3Dnone -eprocess_vm_readv strace -qq -o/dev/null c=
at /dev/null
>=20
> I see. Well, yes, this use-case will not benefit much from remote splice.=
 How about more
> interactive debug by, say, gdb? It may attach, then splice all the memory=
, then analyze
> the victim code/data w/o copying it to its address space?
>=20
> -- Pavel

I may be completely off base, but could a FUSE daemon use this to read memo=
ry from the client and dump it to a file descriptor without copying the dat=
a into the kernel?=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
