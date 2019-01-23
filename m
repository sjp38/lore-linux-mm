Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA45D8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:47:06 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id u197so2049938qka.8
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:47:06 -0800 (PST)
Received: from mail.emypeople.net (mail.emypeople.net. [216.220.167.73])
        by mx.google.com with ESMTP id u189si5490103qkf.44.2019.01.23.06.47.05
        for <linux-mm@kvack.org>;
        Wed, 23 Jan 2019 06:47:06 -0800 (PST)
From: "Edwin Zimmerman" <edwin@211mainstreet.net>
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org> <20190123115829.GA31385@kroah.com> <874l9z31c5.fsf@intel.com>
In-Reply-To: <874l9z31c5.fsf@intel.com>
Subject: RE: [Intel-gfx] [PATCH 1/3] treewide: Lift switch variables out of switches
Date: Wed, 23 Jan 2019 09:47:06 -0500
Message-ID: <000001d4b32a$845e06e0$8d1a14a0$@211mainstreet.net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jani Nikula' <jani.nikula@linux.intel.com>, 'Greg KH' <gregkh@linuxfoundation.org>, 'Kees Cook' <keescook@chromium.org>
Cc: dev@openvswitch.org, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, netdev@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, intel-wired-lan@lists.osuosl.org, linux-fsdevel@vger.kernel.org, xen-devel@lists.xenproject.org, 'Laura Abbott' <labbott@redhat.com>, linux-kbuild@vger.kernel.org, 'Alexander Popov' <alex.popov@linux.com>

On Wed, 23 Jan 2019, Jani Nikula <jani.nikula@linux.intel.com> wrote:
> On Wed, 23 Jan 2019, Greg KH <gregkh@linuxfoundation.org> wrote:
> > On Wed, Jan 23, 2019 at 03:03:47AM -0800, Kees Cook wrote:
> >> Variables declared in a switch statement before any case statements
> >> cannot be initialized, so move all instances out of the switches.
> >> After this, future always-initialized stack variables will work
> >> and not throw warnings like this:
> >>
> >> fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
> >> fs/fcntl.c:738:13: warning: statement will never be executed =
[-Wswitch-unreachable]
> >>    siginfo_t si;
> >>              ^~
> >
> > That's a pain, so this means we can't have any new variables in { }
> > scope except for at the top of a function?
> >
> > That's going to be a hard thing to keep from happening over time, as
> > this is valid C :(
>=20
> Not all valid C is meant to be used! ;)

Very true.  The other thing to keep in mind is the burden of enforcing a =
prohibition on a valid C construct like this. =20
It seems to me that patch reviewers and maintainers have enough to do =
without forcing them to watch for variable
declarations in switch statements.  Automating this prohibition, should =
it be accepted, seems like a good idea to me.

-Edwin Zimmerman
