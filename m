Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F33628D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 08:52:39 -0400 (EDT)
Received: by gxk2 with SMTP id 2so1937250gxk.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 05:52:36 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [RFC PATCH] Add Kconfig option for default swappiness
In-Reply-To: <20101101124322.GG840@cmpxchg.org>
References: <1288548508-22070-1-git-send-email-bgamari.foss@gmail.com> <20101101124322.GG840@cmpxchg.org>
Date: Mon, 01 Nov 2010 08:52:30 -0400
Message-ID: <8739rlnr3l.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Nov 2010 08:43:22 -0400, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Sun, Oct 31, 2010 at 02:08:28PM -0400, Ben Gamari wrote:
> > This will allow distributions to tune this important vm parameter in a more
> > self-contained manner.
> 
> What's wrong with sticking
> 
> 	vm.swappiness = <your value>
> 
> into the shipped /etc/sysctl.conf?

Ubuntu ships different kernels for desktop and server usage. From a
packaging standpoint it would be much nicer to have this set in the
kernel configuration. If we were to throw the setting /etc/sysctl.conf
the kernel would depend upon the package containing sysctl(8)
(procps). We'd rather avoid this and keep the default kernel
configuration in one place. This was just an RFC though; let me know if
you think this is totally insane.

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
