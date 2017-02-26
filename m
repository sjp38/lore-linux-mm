Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5B556B0038
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 07:14:49 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id p36so33862767wrc.7
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 04:14:49 -0800 (PST)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id t19si17630492wrb.187.2017.02.26.04.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Feb 2017 04:14:48 -0800 (PST)
Received: by mail-wr0-x244.google.com with SMTP id q39so7242155wrb.2
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 04:14:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170224001921.wsis65um3jnhtpil@lukather>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <CACvgo51p+aqegjkbF6jGggwr+KXq_71w0VFzJvFAF6_egT1-kA@mail.gmail.com>
 <20170217154419.xr4n2ikp4li3c7co@lukather> <CACvgo51vLca_Ji8VQBO5fqCrbhpm_=6mrqx1K-7GddVv5yMKWg@mail.gmail.com>
 <20170224001921.wsis65um3jnhtpil@lukather>
From: Emil Velikov <emil.l.velikov@gmail.com>
Date: Sun, 26 Feb 2017 12:14:46 +0000
Message-ID: <CACvgo51GKYEiXqV4SMFbucmE5SxLwh7Jd_zNMMWvxZwSRP5pWA@mail.gmail.com>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>, ML dri-devel <dri-devel@lists.freedesktop.org>, Mark Rutland <mark.rutland@arm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, devicetree <devicetree@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>, LAKML <linux-arm-kernel@lists.infradead.org>

Hi Maxime,

Thanks for the links.

On 24 February 2017 at 00:19, Maxime Ripard
<maxime.ripard@free-electrons.com> wrote:
> Hi,
>
> On Fri, Feb 17, 2017 at 08:39:33PM +0000, Emil Velikov wrote:
>> As I feared things have taken a turn for the bitter end :-]
>>
>> It seems that this is a heated topic, so I'l kindly ask that we try
>> the following:
>>
>>  - For people such as myself/Tobias/others who feel that driver and DT
>> bindings should go hand in hand, prove them wrong.
>> But please, do so by pointing to the documentation (conclusion of a
>> previous discussion). This way you don't have to repeat yourself and
>> get [too] annoyed over silly suggestions.
>
> http://lxr.free-electrons.com/source/Documentation/devicetree/usage-model.txt#L13
>
> "The "Open Firmware Device Tree", or simply Device Tree (DT), is a
> data structure and language for describing hardware. More
> specifically, it is a description of hardware that is readable by an
> operating system so that the operating system doesn't need to hard
> code details of the machine"
>
> http://lxr.free-electrons.com/source/Documentation/devicetree/usage-model.txt#L79
>
> "What it does do is provide a language for decoupling the hardware
> configuration from the board and device driver support in the Linux
> kernel (or any other operating system for that matter)."
>
The above seems to imply that there is (merged) device driver support
in the Linux kernel (or other) that uses the bindings.

It's not my call to make any of the policy, so I'll just kindly
suggest improving the existing documentation:
 - Reword/elaborate if out of tree [Linux or in general?] drivers are
suitable counterpart.
 - Patches could/should reference the "other OS" driver, or the "other
OS" name at least ?

Rather than clumping the above in 2.1 a separate section would be better ?

> And like I said, we already had bindings for out of tree bindings,
> like this one:
> https://patchwork.kernel.org/patch/9275707/
>
> Which triggered no discussion at the time (but the technical one,
> hence a v2, that should always be done).
>
Needless to say, there's many of us waiting to see a Mali driver land
- hence the noise. It's not meant to belittle/sway the work you and
others do.

>> - The series has code changes which [seemingly] cater for out of tree
>> module(s).
>
> That patch was dropped, only DT changes remains now, and do not depend
> of that missing patch anyway.
>
>> Clearly state in the commit message who is the user, why it's save to
>> do so and get an Ack from more prominent [DRM] developers.
>
> DRM is really not important here. We could implement a driver using
> i2c as far as the DT is concerned.
>
What I meant to say is:

Please, provide clear expectations from the start - "Linux driver is
OOT with no ETA on landing" or "driver for $FOO OS is at $LINK".
Afaict Hans did the former in the patch mentioned. Perhaps you already
did - in which case pardon for missing it.

> FreeBSD for example uses a different, !DRM framework to support our
> display stack, and still uses the DT.
>
Interesting - do you have a link handy ? Does it use open-source usespace ?

Thanks
Emil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
