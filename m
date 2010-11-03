Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AF1E88D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 10:34:12 -0400 (EDT)
Date: Wed, 3 Nov 2010 10:33:59 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
Message-ID: <20101103143358.GA19777@redhat.com>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com>
 <alpine.DEB.2.00.1011012030100.12298@chino.kir.corp.google.com>
 <87oca7evbo.fsf@gmail.com>
 <20101102140119.GA8294@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101102140119.GA8294@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Ben Gamari <bgamari.foss@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jesper Juhl <jj@chaosbits.net>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 02, 2010 at 10:01:20PM +0800, Wu Fengguang wrote:
 
 > > On Mon, Nov 01, 2010 at 08:52:30AM -0400, Ben Gamari wrote:
 > > > Ubuntu ships different kernels for desktop and server usage. From a
 > > > packaging standpoint it would be much nicer to have this set in the
 > > > kernel configuration. If we were to throw the setting /etc/sysctl.conf
 > > > the kernel would depend upon the package containing sysctl(8)
 > > > (procps). We'd rather avoid this and keep the default kernel
 > > > configuration in one place.
 > > 
 > > In short, being able to specify this default in .config is just far
 > > simpler from a packaging standpoint than the alternatives.
 > 
 > It's interesting to know what value you plan to use for your
 > desktop/server systems and the rationals (is it based on any
 > testing results?). And why it's easier to do it in kernel (hope it's
 > not because of trouble communicating with the user space packaging
 > team).

Not sure why I was cc'd on this, but at least for Fedora, we still take
the 'one kernel to rule them all' approach for every spin (and will likely
continue to do so to maximise coverage testing) so a config option for us
for things like this is moot.

Whenever I've tried to push changes to our defaults through to our
default /etc/sysctl.conf, it's been met with resistance due to beliefs
that a) the file is there for _users_ to override decisions
the distro made at build time and b) if this is the right default,
why isn't the kernel setting it?

The idea keeps coming up to have some userspace thing automatically
tune the kernel to dtrt based upon whatever profile it has been fed.
Various implementations of things like this have come and gone
(Arjan and myself even wrote one circa 2000). For whatever reason,
they don't seem to catch on.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
