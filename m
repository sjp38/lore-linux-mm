Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 99C9D6B00A9
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 23:09:31 -0400 (EDT)
Received: by qyk4 with SMTP id 4so847524qyk.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 20:09:30 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
In-Reply-To: <20101102140119.GA8294@localhost>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com> <alpine.DEB.2.00.1011012030100.12298@chino.kir.corp.google.com> <87oca7evbo.fsf@gmail.com> <20101102140119.GA8294@localhost>
Date: Wed, 03 Nov 2010 23:09:27 -0400
Message-ID: <87aalpbx94.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jesper Juhl <jj@chaosbits.net>, Dave Jones <davej@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Nov 2010 22:01:20 +0800, Wu Fengguang <fengguang.wu@intel.com> wrote:
> It's interesting to know what value you plan to use for your
> desktop/server systems and the rationals (is it based on any
> testing results?).

This is something that will likely require a great deal of research,
thinking, and testing. I wish I could give you a better answer at the
moment. I have read many opinions on this but have not seen enough
evidence to suggest specific values. In the desktop case, it seems clear
that the preferred value should be lower than the current default to
preserve interactive performance (long latencies due to swapping is
something that many desktop users complain about currently). I set
swappiness to 10 on my own machines machines with good results, but mine
is anything but a model case. I don't believe there is any direct need
to touch the server kernel swappiness at the moment.

> And why it's easier to do it in kernel (hope it's not because of
> trouble communicating with the user space packaging team).

Fear not, this is certainly not the case. We would simply like to be
able to keep this our kernel configuration self-contained. We already
have separate packages for various kernel flavors with their own
configurations. Allowing us to tune swappiness from the configuration
would keep things much cleaner.

The other option would be to drop a file in /etc/sysctl.d from the
kernel meta-package (e.g. linux-image-generic and
linux-image-server). However, it would make little sense to do this
without adding a dependency on procps to this package (although,
admittedly, procps is in the default installation) which we would rather
not do if possible. Furthermore, this spreads the kernel configuration
across the system. In sum, it seems that configuring the default in the
kernel itself is by far the most elegant way to proceed.

Cheers,

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
