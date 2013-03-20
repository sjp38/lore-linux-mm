Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 842256B0005
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 00:12:33 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id j1so1315038oag.21
        for <linux-mm@kvack.org>; Tue, 19 Mar 2013 21:12:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51489979.2070403@draigBrady.com>
References: <5121C7AF.2090803@numascale-asia.com>
	<CAJd=RBArPT8YowhLuE8YVGNfH7G-xXTOjSyDgdV2RsatL-9m+Q@mail.gmail.com>
	<51254AD2.7000906@suse.cz>
	<CAJd=RBCiYof5rRVK+62OFMw+5F=5rS=qxRYF+OHpuRz895bn4w@mail.gmail.com>
	<512F8D8B.3070307@suse.cz>
	<CAJd=RBD=eT=xdEy+v3GBZ47gd47eB+fpF-3VtfpLAU7aEkZGgA@mail.gmail.com>
	<5138EC6C.6030906@suse.cz>
	<CAJd=RBC6JzXzPn9OV8UsbEjX152RcbKpuGGy+OBGM6E43gourQ@mail.gmail.com>
	<513A7263.5090303@suse.cz>
	<51489979.2070403@draigBrady.com>
Date: Wed, 20 Mar 2013 12:12:32 +0800
Message-ID: <CAJd=RBCfMj7SUOE64KWXv6fcdASQWZV_Taujrtf4mDo8fFKBhw@mail.gmail.com>
Subject: Re: kswapd craziness round 2
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigbrady.com>
Cc: Jiri Slaby <jslaby@suse.cz>, Daniel J Blueman <daniel@numascale-asia.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>, mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

On Wed, Mar 20, 2013 at 12:59 AM, P=C3=A1draig Brady <P@draigbrady.com> wro=
te:
>
> I notice the same thunderbird issue on the much older 2.6.40.4-5.fc15.x86=
_64
> which I'd hoped would be fixed on upgrade :(
>
> My Thunderbird is using 1957m virt, 722m RSS on my 3G system.
> What are your corresponding mem values?
>
> For reference:
> http://marc.info/?t=3D130865025500001&r=3D1&w=3D2
> https://bugzilla.redhat.com/show_bug.cgi?id=3D712019
>
Hey, would you all please try Mels new work?
http://marc.info/?l=3Dlinux-mm&m=3D136352546814642&w=3D4

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
