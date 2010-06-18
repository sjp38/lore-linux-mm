Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CC3FB6B01D0
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 09:25:15 -0400 (EDT)
Received: by yxf34 with SMTP id 34so141887yxf.14
        for <linux-mm@kvack.org>; Fri, 18 Jun 2010 06:25:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1276866058.28780.48.camel@e102109-lin.cambridge.arm.com>
References: <AANLkTimb7rP0rS0OU8nan5uNEhHx_kEYL99ImZ3c8o0D@mail.gmail.com>
	<1276866058.28780.48.camel@e102109-lin.cambridge.arm.com>
Date: Fri, 18 Jun 2010 18:55:13 +0530
Message-ID: <AANLkTimjLtQJmfjW31aRMPyY9XTVCwNCfTR_JU_0apbd@mail.gmail.com>
Subject: Re: Probable Bug (or configuration error) in kmemleak
From: Sankar P <sankar.curiosity@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>, rnagarajan@novell.com, teheo@novell.com, Pekka Enberg <penberg@cs.helsinki.fi>, Luis Rodriguez <Luis.Rodriguez@atheros.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 18, 2010 at 6:30 PM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> On Fri, 2010-06-18 at 09:11 +0100, Sankar P wrote:
>> On Thu, Jun 17, 2010 at 11:06 PM, Luis R. Rodriguez
>> <lrodriguez@atheros.com> wrote:
>> > On Thu, Jun 17, 2010 at 02:21:56AM -0700, Sankar P wrote:
>> >> Hi,
>> >>
>> >> I wanted to detect memory leaks in one of my kernel modules. So I
>> >> built Linus' tree =A0with the following config options enabled (on to=
p
>> >> of make defconfig)
>> >>
>> >> CONFIG_DEBUG_KMEMLEAK=3Dy
>> >> CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=3D400
>> >> CONFIG_DEBUG_KMEMLEAK_TEST=3Dy
>> >>
>> >> If I boot with this kernel, debugfs is automatically mounted. But I d=
o
>> >> not have the file:
>> >>
>> >> /sys/kernel/debug/kmemleak
>> >>
>> >> created at all. There are other files like kprobes in the mounted
>> >> /sys/kernel/debug directory btw. So I am not able to detect any of th=
e
>> >> memory leaks. Is there anything I am doing wrong or missing (or) is
>> >> this a bug in kmemleak ?
>> >>
>> >> Please let me know your suggestions to fix this and get memory leaks
>> >> reporting working. Thanks.
>> >>
>> >> The full .config file is also attached with this mail. Sorry for the
>> >> attachment, I did not want to paste 5k lines in the mail. Sorry if it
>> >> is wrong.
>> >
>> >
>> > This is odd.. Do you see this message on your kernel ring buffer?
>> >
>> > Failed to create the debugfs kmemleak file
>> >
>>
>> I dont see such an error in the dmesg output. But I got another
>> interesting error:
>>
>> [ =A0 =A00.000000] kmemleak: Early log buffer exceeded, please increase
>> DEBUG_KMEMLEAK_EARLY_LOG_SIZE
>> [ =A0 =A00.000000] kmemleak: Kernel memory leak detector disabled
>
> You would need to increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE. The default of
> 400 seems ok for me but it may not work with some other kernel
> configurations (that's a static array for logging memory allocations
> before the kmemleak is fully initialised and can start tracking them).
>
>> But after that also, I see some other lines like:
>>
>> [ =A0 =A00.511641] kmemleak: vmalloc(64) =3D f7857000
>> [ =A0 =A00.511645] kmemleak: vmalloc(64) =3D f785a000
>
> This is because you compiler the test module into the kernel
> (DEBUG_KMEMLEAK_TEST). It's not kmemleak printing this but it's testing
> module (which leaks memory on purpose).
>
>> The variable =A0DEBUG_KMEMLEAK_EARLY_LOG_SIZE was set to 400 by default.
>> I changed it to 4000 and then 40000 (may be should try < 32567 ?) but
>> still I get the same error message and the file
>> /sys/kernel/debug/kmem* is never created at all.
>
> This shouldn't usually happen with values greater than 2000. From your
> kernel log, the version seems to be 2.6.32. Do you have the same
> problems with 2.6.35-rc3?
>
> Your .config seems to refer to the 2.6.35-rc3 kernel - are you checking
> the right image?
>

Ah sorry. I am testing by ssh into a remote machine. After installing
my kernel (after increasing the DEBUG_KMEMLEAK_EARLY_LOG_SIZE), Before
rebooting, I forgot to change the default-kernel this time. I will
check once again and will let you know. Thank you a lot for the
"dmesg" pointer.


--=20
Sankar P
http://psankar.blogspot.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
