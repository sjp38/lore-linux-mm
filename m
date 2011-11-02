Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 58EA96B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 22:37:44 -0400 (EDT)
Received: by qadc11 with SMTP id c11so8268766qad.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 19:37:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.00.1110281044410.11733@tundra.namei.org>
References: <CAH-7YMmqs9j2-UTUSCZaFDEhxmjkAZvHzKVvbvy7nsG8JpFA9w@mail.gmail.com>
	<alpine.LRH.2.00.1110210232450.31056@tundra.namei.org>
	<CAH-7YMmx0J+pQFfrU4KW2ahFDPL3udvAUgPy4_Hf19HP46MZHw@mail.gmail.com>
	<CAH-7YMmAM8e051PopL92WhqSvqz23_eWKjfZbuaLZ4_UhGR5jw@mail.gmail.com>
	<alpine.LRH.2.00.1110271718510.5714@tundra.namei.org>
	<alpine.LRH.2.00.1110281044410.11733@tundra.namei.org>
Date: Wed, 2 Nov 2011 10:37:41 +0800
Message-ID: <CAH-7YMnsKTg-CgBaHXzzYV4WBxRGxBbEfHpUUMS9UyzV+12d1g@mail.gmail.com>
Subject: Re: [PATCH] ACL supports to mqueue
From: Zhou Peng <ailvpeng25@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morris <jmorris@namei.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Chris Wright <chrisw@sous-sol.org>, Hugh Dickins <hughd@google.com>, Stephen Smalley <sds@tycho.nsa.gov>, Kentaro Takeda <takedakn@nttdata.co.jp>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, John Johansen <john.johansen@canonical.com>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, linux-security-module@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org

Sorry for late reply, the mail skiped the inbox
and to the lkml label directly of gmail.
On Fri, Oct 28, 2011 at 7:47 AM, James Morris <jmorris@namei.org> wrote:
> On Thu, 27 Oct 2011, James Morris wrote:
>
>> On Tue, 25 Oct 2011, Zhou Peng wrote:
>>
>> > Hi, how about this patch pls?
>>
>> I'm not convinced that this is a necessary feature for the mainline
>> kernel.
>
> It also needs more review, from at least other security folk, and ideally
> also from fs/vfs folk.
Thank you James.
I cc to Alexander Viro (VFS),
Chris Wright (LSM),
Hugh Dickins (TMPFS),
Stephen Smalley (SELINUX),
Kentaro Takeda, Tetsuo Handa (TOMOYO),
John Johansen (APPARMOR)
Hope any review
> Why does NFSARK want this supportr? =A0Are its users asking for it? =A0(I
> couldn't find the distro, btw).
Yes, it's user asks for acl for ipc,
It is a distro by nfschina.
>>
>> >
>> > On Fri, Oct 21, 2011 at 6:46 PM, Zhou Peng <ailvpeng25@gmail.com> wrot=
e:
>> > > * In general, it can give a more fine grained and flexible DAC to ms=
g queue obj.
>> > > * NFSARK(A distro) wants all posix ipc objects to support ACL, inclu=
ding mqueue.
>> > > * Posix semphore and shmem both support ACL, but mqueue as one of th=
e
>> > > three basic ipc doesn't.
>> > > * At least, it may save one note sentence for MQ_OVERVIEW(7) =A0 ^_^
>> > > =A0 =A0"Linux does not currently (2.6.26) support the use of access
>> > > control lists (ACLs) for POSIX message queues."
>> > > =A0 =A0http://www.kernel.org/doc/man-pages/online/pages/man7/mq_over=
view.7.html
>> > >
>> > > On Thu, Oct 20, 2011 at 11:33 PM, James Morris <jmorris@namei.org> w=
rote:
>> > > > On Thu, 20 Oct 2011, Zhou Peng wrote:
>> > > >
>> > > >> This patch adds ACL supports to mqueue filesystem.
>> > > >> Based on Linux 3.0.4.
>> > > >
>> > > > Why is this necessary, and who is planning to use it?
>> > > >
>> > > > Are any distros likely to enable this?

--=20
Zhou Peng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
