Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 19F7A6B13F1
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 07:36:44 -0500 (EST)
Received: by wera13 with SMTP id a13so2538144wer.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 04:36:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F33D2F1.5000606@redhat.com>
References: <201202041109.53003.toralf.foerster@gmx.de>
	<201202051107.26634.toralf.foerster@gmx.de>
	<CAJd=RBCvvVgWqfSkoEaWVG=2mwKhyXarDOthHt9uwOb2fuDE9g@mail.gmail.com>
	<201202080956.18727.toralf.foerster@gmx.de>
	<20120208115244.GA24959@sig21.net>
	<CAJd=RBDbYA4xZRikGtHJvKESdiSE-B4OucZ6vQ+tHCi+hG2+aw@mail.gmail.com>
	<20120209113606.GA8054@sig21.net>
	<CAJd=RBDzUpUgZLVU+WSfb8grzMAbi3fcyyZkpX8qpaxu6zYe1g@mail.gmail.com>
	<20120209132155.GA15147@sig21.net>
	<20120209135407.GA15492@sig21.net>
	<4F33D2F1.5000606@redhat.com>
Date: Fri, 10 Feb 2012 20:36:42 +0800
Message-ID: <CAJd=RBBqGpgn=9R5-T0YOOzsQcS1L7V=T2v8upTHp8ARczZJGQ@mail.gmail.com>
Subject: Re: swap storm since kernel 3.2.x
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Stezenbach <js@sig21.net>, =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 9, 2012 at 10:06 PM, Rik van Riel <riel@redhat.com> wrote:
> On 02/09/2012 08:54 AM, Johannes Stezenbach wrote:
>>
>> On Thu, Feb 09, 2012 at 02:21:55PM +0100, Johannes Stezenbach wrote:
>>>
>>> it looks good. =C2=A0Neither do I get the huge debug_objects_cache
>>> nor does it swap, after running a crosstool-ng toolchain build.
>>> Well, last time I also had one kvm -m 1G instance running. =C2=A0I'll
>>> try if that triggers the issue. =C2=A0So far:
>>
>>
>> The kvm produced a bunch of page allocation failures
>> on the host:
>
>
>> (repeats a few times)
>>
>> I guess that is expected with your patch?
>
>
> That is indeed why my patch series was significantly larger
> than Hillf's little test patch :)
>

Yes, Johannes did show that kswapd running purely in single
mode, without helps from compaction or lumpy, could not
meet all requests in VM core.

Thank you all
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
