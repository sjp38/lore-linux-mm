Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 32BAD6B007B
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 00:38:31 -0500 (EST)
Received: by ywh5 with SMTP id 5so47420851ywh.11
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:38:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1263271018.23507.8.camel@barrios-desktop>
References: <1263271018.23507.8.camel@barrios-desktop>
Date: Tue, 12 Jan 2010 11:00:18 +0530
Message-ID: <d760cf2d1001112130p8489b93uccd6a4650ff4a4a8@mail.gmail.com>
Subject: Re: [PATCH] Fix reset of ramzswap
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "minchan.kim" <minchan.kim@gmail.com>
Cc: Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 12, 2010 at 10:06 AM, minchan.kim <minchan.kim@gmail.com> wrote=
:
> ioctl(cmd=3Dreset)
> =A0 =A0 =A0 =A0-> bd_holder check (if whoever hold bdev, return -EBUSY)
> =A0 =A0 =A0 =A0-> ramzswap_ioctl_reset_device
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0-> reset_device
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0-> bd_release
>
> bd_release is called by reset_device.
> but ramzswap_ioctl always checks bd_holder before
> reset_device. it means reset ioctl always fails.

Are you sure you checked this patch?

This check makes sure that you cannot reset an active swap device.
When device in swapoff'ed the ioctl works as expected.

Greg: Can you please exclude earlier 'Free memory when create_device
is failed' patch?
That patch is correct however, my pending patch series conflicts with
that. So, I will
instead include that fix with this patch series (and add appropriate
signed-off-by)

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
