From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH v2] ipc,shm: document new limits in the uapi header
Date: Mon, 12 May 2014 09:44:13 +0200
Message-ID: <CAKgNAkhKubCUiTK36vT98vPbrfLd=xBBxeyPfUfzsqS-uHWAbA@mail.gmail.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
 <CAKgNAkjuU68hgyMOVGBVoBTOhhGdBytQh6H0ExiLoXfujKyP_w@mail.gmail.com>
 <1399406800.13799.20.camel@buesod1.americas.hpqcorp.net> <CAKgNAkjOKP7P9veOpnokNkVXSszVZt5asFsNp7rm7AXJdjcLLA@mail.gmail.com>
 <1399414081.30629.2.camel@buesod1.americas.hpqcorp.net> <5369C43D.1000206@gmail.com>
 <1399486965.4567.9.camel@buesod1.americas.hpqcorp.net> <1399490251.4567.24.camel@buesod1.americas.hpqcorp.net>
 <CAKgNAkgZ+7=EB4jkCdvq5EK1ce03rq9j+rEss9N1XnUQytBcGg@mail.gmail.com> <1399841186.8629.6.camel@buesod1.americas.hpqcorp.net>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399841186.8629.6.camel@buesod1.americas.hpqcorp.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Hi Davidlohr,

On Sun, May 11, 2014 at 10:46 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> On Fri, 2014-05-09 at 10:44 +0200, Michael Kerrisk (man-pages) wrote:
>> On Wed, May 7, 2014 at 9:17 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>> > This is useful in the future and allows users to
>> > better understand the reasoning behind the changes.
>> >
>> > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
>> > ---
>> >  include/uapi/linux/shm.h | 15 +++++++++------
>> >  1 file changed, 9 insertions(+), 6 deletions(-)
>> >
>> > diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
>> > index 74e786d..3400b6e 100644
>> > --- a/include/uapi/linux/shm.h
>> > +++ b/include/uapi/linux/shm.h
>> > @@ -8,17 +8,20 @@
>> >  #endif
>> >
>> >  /*
>> > - * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
>> > - * be modified by sysctl.
>> > + * SHMMNI, SHMMAX and SHMALL are the default upper limits which can be
>> > + * modified by sysctl. Both SHMMAX and SHMALL have their default values
>> > + * to the maximum limit which is as large as it can be without helping
>> > + * userspace overflow the values. There is really nothing the kernel
>> > + * can do to avoid this any further. It is therefore not advised to
>> > + * make them any larger. These limits are suitable for both 32 and
>> > + * 64-bit systems.
>>
>> I somehow find that text still rather impenetrable. What about this:
>>
>> SHMMNI, SHMMAX and SHMALL are default upper limits which can be
>> modified by sysctl. The SHMMAX and SHMALL values have been chosen to
>> be as large possible without facilitating scenarios where userspace
>> causes overflows when adjusting the limits via operations of the form
>> "retrieve current limit; add X; update limit". It is therefore not
>> advised to make SHMMAX and SHMALL any larger. These limits are
>> suitable for both 32 and 64-bit systems.
>
> I don't really have much preference, imho both read pretty much the
> same, specially considering this is still code after all. If you guys
> really prefer updating it, let me know and I'll send a v3. But perhaps
> your text is a bit more suitable in the svipc manpage?

The problem is that part of your text is still broken grammatically In
particular, the piece "Both SHMMAX and SHMALL have their default
values to the maximum limit" at the very least lacks a word. That's
what prompted me to propose the alternative, rather than just say
"this is wrong"--and I thought that I might as well make a more
thoroughgoing attempt at helping improve the text.

I agree that text something like this should land in the man page at
some point, but as long as we're going to the trouble to improve the
comments in the code, let's make them as good and helpful as we can.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
