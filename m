Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 323346B0172
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 08:58:30 -0400 (EDT)
Received: by ywl5 with SMTP id 5so3862878ywl.14
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 05:58:27 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
In-Reply-To: <alpine.DEB.2.00.1011012030100.12298@chino.kir.corp.google.com>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com> <alpine.DEB.2.00.1011012030100.12298@chino.kir.corp.google.com>
Date: Tue, 02 Nov 2010 08:58:19 -0400
Message-ID: <87oca7evbo.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Juhl <jj@chaosbits.net>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Nov 2010 20:33:10 -0700 (PDT), David Rientjes <rientjes@google.com> wrote:
> And they can't use an init script to tune /proc/sys/vm/swappiness 
> because...?

Packaging concerns, as I mentioned before,

On Mon, Nov 01, 2010 at 08:52:30AM -0400, Ben Gamari wrote:
> Ubuntu ships different kernels for desktop and server usage. From a
> packaging standpoint it would be much nicer to have this set in the
> kernel configuration. If we were to throw the setting /etc/sysctl.conf
> the kernel would depend upon the package containing sysctl(8)
> (procps). We'd rather avoid this and keep the default kernel
> configuration in one place.

In short, being able to specify this default in .config is just far
simpler from a packaging standpoint than the alternatives.

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
