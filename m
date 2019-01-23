Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C10AE8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 10:44:46 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d71so1736169pgc.1
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 07:44:46 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 1si19383796pld.239.2019.01.23.07.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 07:44:45 -0800 (PST)
From: Jani Nikula <jani.nikula@linux.intel.com>
Subject: RE: [Intel-gfx] [PATCH 1/3] treewide: Lift switch variables out of switches
In-Reply-To: <000001d4b32a$845e06e0$8d1a14a0$@211mainstreet.net>
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org> <20190123115829.GA31385@kroah.com> <874l9z31c5.fsf@intel.com> <000001d4b32a$845e06e0$8d1a14a0$@211mainstreet.net>
Date: Wed, 23 Jan 2019 17:46:14 +0200
Message-ID: <87va2f1int.fsf@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Edwin Zimmerman <edwin@211mainstreet.net>, 'Greg KH' <gregkh@linuxfoundation.org>, 'Kees Cook' <keescook@chromium.org>
Cc: dev@openvswitch.org, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, netdev@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, intel-wired-lan@lists.osuosl.org, linux-fsdevel@vger.kernel.org, xen-devel@lists.xenproject.org, 'Laura Abbott' <labbott@redhat.com>, linux-kbuild@vger.kernel.org, 'Alexander Popov' <alex.popov@linux.com>

On Wed, 23 Jan 2019, Edwin Zimmerman <edwin@211mainstreet.net> wrote:
> On Wed, 23 Jan 2019, Jani Nikula <jani.nikula@linux.intel.com> wrote:
>> On Wed, 23 Jan 2019, Greg KH <gregkh@linuxfoundation.org> wrote:
>> > On Wed, Jan 23, 2019 at 03:03:47AM -0800, Kees Cook wrote:
>> >> Variables declared in a switch statement before any case statements
>> >> cannot be initialized, so move all instances out of the switches.
>> >> After this, future always-initialized stack variables will work
>> >> and not throw warnings like this:
>> >>
>> >> fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
>> >> fs/fcntl.c:738:13: warning: statement will never be executed [-Wswitc=
h-unreachable]
>> >>    siginfo_t si;
>> >>              ^~
>> >
>> > That's a pain, so this means we can't have any new variables in { }
>> > scope except for at the top of a function?
>> >
>> > That's going to be a hard thing to keep from happening over time, as
>> > this is valid C :(
>>=20
>> Not all valid C is meant to be used! ;)
>
> Very true.  The other thing to keep in mind is the burden of enforcing
> a prohibition on a valid C construct like this.  It seems to me that
> patch reviewers and maintainers have enough to do without forcing them
> to watch for variable declarations in switch statements.  Automating
> this prohibition, should it be accepted, seems like a good idea to me.

Considering that the treewide diffstat to fix this is:

 18 files changed, 45 insertions(+), 46 deletions(-)

and using the gcc plugin in question will trigger the switch-unreachable
warning, I think we're good. There'll probably be the occasional
declarations that pass through, and will get fixed afterwards.

BR,
Jani.

--=20
Jani Nikula, Intel Open Source Graphics Center
