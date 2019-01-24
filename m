Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 027838E0047
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 03:10:29 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b17so3978211pfc.11
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 00:10:28 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d82si21001951pfj.124.2019.01.24.00.10.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 00:10:27 -0800 (PST)
Date: Thu, 24 Jan 2019 09:10:24 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [Intel-gfx] [PATCH 1/3] treewide: Lift switch variables out of
 switches
Message-ID: <20190124081024.GA1108@kroah.com>
References: <20190123110349.35882-1-keescook@chromium.org>
 <20190123110349.35882-2-keescook@chromium.org>
 <20190123115829.GA31385@kroah.com>
 <874l9z31c5.fsf@intel.com>
 <000001d4b32a$845e06e0$8d1a14a0$@211mainstreet.net>
 <87va2f1int.fsf@intel.com>
 <CAGXu5jJUxHtFq0rBJ9FwzMcZDWnusPUauC_=MaOz7H0_PF25jQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAGXu5jJUxHtFq0rBJ9FwzMcZDWnusPUauC_=MaOz7H0_PF25jQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Jani Nikula <jani.nikula@linux.intel.com>, Edwin Zimmerman <edwin@211mainstreet.net>, dev@openvswitch.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Network Development <netdev@vger.kernel.org>, intel-gfx@lists.freedesktop.org, linux-usb@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Linux-MM <linux-mm@kvack.org>, linux-security-module <linux-security-module@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, intel-wired-lan@lists.osuosl.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, xen-devel <xen-devel@lists.xenproject.org>, Laura Abbott <labbott@redhat.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Alexander Popov <alex.popov@linux.com>

On Thu, Jan 24, 2019 at 07:55:51AM +1300, Kees Cook wrote:
> On Thu, Jan 24, 2019 at 4:44 AM Jani Nikula <jani.nikula@linux.intel.com> wrote:
> >
> > On Wed, 23 Jan 2019, Edwin Zimmerman <edwin@211mainstreet.net> wrote:
> > > On Wed, 23 Jan 2019, Jani Nikula <jani.nikula@linux.intel.com> wrote:
> > >> On Wed, 23 Jan 2019, Greg KH <gregkh@linuxfoundation.org> wrote:
> > >> > On Wed, Jan 23, 2019 at 03:03:47AM -0800, Kees Cook wrote:
> > >> >> Variables declared in a switch statement before any case statements
> > >> >> cannot be initialized, so move all instances out of the switches.
> > >> >> After this, future always-initialized stack variables will work
> > >> >> and not throw warnings like this:
> > >> >>
> > >> >> fs/fcntl.c: In function ‘send_sigio_to_task’:
> > >> >> fs/fcntl.c:738:13: warning: statement will never be executed [-Wswitch-unreachable]
> > >> >>    siginfo_t si;
> > >> >>              ^~
> > >> >
> > >> > That's a pain, so this means we can't have any new variables in { }
> > >> > scope except for at the top of a function?
> 
> Just in case this wasn't clear: no, it's just the switch statement
> before the first "case". I cannot imagine how bad it would be if we
> couldn't have block-scoped variables! Heh. :)

Sorry, it was not clear at first glance.  So no more objection from me
for this change.

greg k-h
