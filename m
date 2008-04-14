Date: Mon, 14 Apr 2008 00:48:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: fix oops in oom handling
Message-Id: <20080414004822.cd1c5498.akpm@linux-foundation.org>
In-Reply-To: <20080414162404.b5340fe9.kamezawa.hiroyu@jp.fujitsu.com>
References: <4802FF10.6030905@cn.fujitsu.com>
	<20080414162404.b5340fe9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Paul Menage <menage@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Apr 2008 16:24:04 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 14 Apr 2008 14:52:00 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> > It's reproducable in a x86_64 box, but doesn't happen in x86_32.
> > 
> > This is because tsk->sighand is not guarded by RCU, so we have to
> > hold tasklist_lock, just as what out_of_memory() does.
> > 
> > Signed-off-by: Li Zefan <lizf@cn.fujitsu>
> 
> Andrew, fast-path for 2.6.25 is still not-closed ?

If it was closed, there'd be no point in having rc9 ;)

> I think this patch is worth
> to be merged as bugfix to 2.6.25 if enough acks.

Yes, it's in my for-2.6.25 queue:

mmc-fix-platform-driver-hotplug-coldplug.patch
rtc-fix-the-error-in-the-function-of-cmos_set_alarm.patch
leds-fix-platform-driver-hotplug-coldplug.patch
fbdev-fix-proc-fb-oops-after-module-removal.patch
fix-sys_unsharesem_undo-add-support-for-clone_sysvsem.patch
fix-sys_unsharesem_undo-add-support-for-clone_sysvsem-cleanup.patch
fix-sys_unsharesem_undo-perform-an-implicit-clone_sysvsem-in-clone_newipc.patch
misc-fix-platform-driver-hotplug-coldplug.patch
pcmcia-fix-platform-driver-hotplug-coldplug.patch
serial-fix-platform-driver-hotplug-coldplug.patch
memcg-fix-oops-in-oom-handling.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
