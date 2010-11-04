Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 55DD36B00A9
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 22:40:57 -0400 (EDT)
Received: by qwi2 with SMTP id 2so820689qwi.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 19:40:55 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
In-Reply-To: <20101103143358.GA19777@redhat.com>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com> <alpine.DEB.2.00.1011012030100.12298@chino.kir.corp.google.com> <87oca7evbo.fsf@gmail.com> <20101102140119.GA8294@localhost> <20101103143358.GA19777@redhat.com>
Date: Wed, 03 Nov 2010 22:40:52 -0400
Message-ID: <87hbfxbykr.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Dave Jones <davej@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jesper Juhl <jj@chaosbits.net>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Nov 2010 10:33:59 -0400, Dave Jones <davej@redhat.com> wrote:
> Not sure why I was cc'd on this, but at least for Fedora, we still take
> the 'one kernel to rule them all' approach for every spin (and will likely
> continue to do so to maximise coverage testing) so a config option for us
> for things like this is moot.
> 
Just didn't want to miss anyone important. Sorry for the noise.

> Whenever I've tried to push changes to our defaults through to our
> default /etc/sysctl.conf, it's been met with resistance due to beliefs
> that a) the file is there for _users_ to override decisions
> the distro made at build time and b) if this is the right default,
> why isn't the kernel setting it?
>
This seems to be the consensus within the Ubuntu community as well. I
don't have any strong opinion either way but I will admit that setting
it in userspace does make the packaging issue messy.

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
