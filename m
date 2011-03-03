Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 602DA8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:26:24 -0500 (EST)
Received: by pwi10 with SMTP id 10so236676pwi.14
        for <linux-mm@kvack.org>; Thu, 03 Mar 2011 00:26:19 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <201103030127.p231ReNl012841@imap1.linux-foundation.org>
References: <201103030127.p231ReNl012841@imap1.linux-foundation.org>
Date: Thu, 3 Mar 2011 09:26:19 +0100
Message-ID: <AANLkTik30hTxPxJHbdeN-b4JqA2WpMh4FcYPgmPdx5+v@mail.gmail.com>
Subject: Re: mmotm 2011-03-02-16-52 uploaded
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Mar 3, 2011 at 1:52 AM,  <akpm@linux-foundation.org> wrote:
> The mm-of-the-moment snapshot 2011-03-02-16-52 has been uploaded to
>
> =C2=A0 http://userweb.kernel.org/~akpm/mmotm/
>
> and will soon be available at
>
> =C2=A0 git://zen-kernel.org/kernel/mmotm.git
>
> It contains the following patches against 2.6.38-rc7:
>
[...]
> backlight-add-backlight-type.patch
> backlight-add-backlight-type-fix.patch
> backlight-add-backlight-type-fix-fix.patch
> i915-add-native-backlight-control.patch
> radeon-expose-backlight-class-device-for-legacy-lvds-encoder.patch
> radeon-expose-backlight-class-device-for-legacy-lvds-encoder-update.patch
> nouveau-change-the-backlight-parent-device-to-the-connector-not-the-pci-d=
ev.patch
> acpi-tie-acpi-backlight-devices-to-pci-devices-if-possible.patch
> mbp_nvidia_bl-remove-dmi-dependency.patch
> mbp_nvidia_bl-check-that-the-backlight-control-functions.patch
> mbp_nvidia_bl-rename-to-apple_bl.patch
> backlight-apple_bl-depends-on-acpi.patch
> drivers-video-backlight-jornada720_c-make-needlessly-global-symbols-stati=
c.patch
[...]

And Sedat asked and is asking again for backlight (acpi + drm-2.6)
patches to go into 2.6.39...

There were 5 patches from Matthew Garrett...
IIRC you told me you took over backlight stuff from Richard Purdie
(hope I recall the name correctly).
First it is a bit hard for me to assign your changed patch names to
the original ones.
There are patches from your tree being recognised for linux-next...
What's up with the backlight ones?
Unfortunately, the last working linux-next (next-20110224) and the
patchset (I have maintained here) do not apply due to recent changes
in linux-next this week.
(Mostly the big patch 1-5 required adaptation to fit linux-next.)
And yes, I am a bit sick of it, so I kicked them for now.

I am not sure what is the ideal way to let these 5 patches (and more?)
go into linux-next (aka for-2.6.39)
But for the mentionned patchset platform-drivers-x86.git#linux-next
could be a good choice (it is automatically pulled into linux-next),
but this would mean Matthew has to do the work...

Anyway, I want to see this patchset in 2.6.39.

BTW, the below listed patchset was take #2 from Matthew.
I am sure take #3 will make me and others happy :-).

- Sedat -

$ ls -lR backlight-type/
backlight-type/:
insgesamt 80
-rw-r--r-- 1 sd sd 39541 23. Feb 09:19 1-5-Backlight-Add-backlight-type-v6.=
patch
-rw-r--r-- 1 sd sd  7389 15. Jan 15:18
2-5-i915-Add-native-backlight-control.patch
-rw-r--r-- 1 sd sd  7083 15. Jan 15:19
4-5-nouveau-Change-the-backlight-parent-device-to-the-connector-not-the-PCI=
-dev.patch
-rw-r--r-- 1 sd sd  2040 15. Jan 15:19
5-5-ACPI-Tie-ACPI-backlight-devices-to-PCI-devices-if-possible.patch
-rw-r--r-- 1 sd sd 13723 20. Jan 20:56
drm-radeon-kms-Expose-backlight-class-device-for-legacy-LVDS-encoder-v2.pat=
ch
drwxr-xr-x 2 sd sd  4096  8. Feb 17:39 orig

backlight-type/orig:
insgesamt 56
-rw-r--r-- 1 sd sd 39265 15. Jan 15:17 1-5-Backlight-Add-backlight-type.pat=
ch
-rw-r--r-- 1 sd sd 13905 15. Jan 15:18
3-5-radeon-Expose-backlight-class-device-for-legacy-LVDS-encoder.patch

-EOT-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
