Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CEC0D6B00A7
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 10:34:29 -0400 (EDT)
Received: by eydd26 with SMTP id d26so3647301eyd.14
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 07:34:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87oca7evbo.fsf@gmail.com>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com>
	<alpine.DEB.2.00.1011012030100.12298@chino.kir.corp.google.com>
	<87oca7evbo.fsf@gmail.com>
Date: Tue, 2 Nov 2010 23:34:27 +0900
Message-ID: <AANLkTimDPdDHAg0Odp0WchOLKh3OUSOWX7_0ps8eizFk@mail.gmail.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Juhl <jj@chaosbits.net>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

2010/11/2 Ben Gamari <bgamari.foss@gmail.com>:
> On Mon, 1 Nov 2010 20:33:10 -0700 (PDT), David Rientjes <rientjes@google.com> wrote:
>> And they can't use an init script to tune /proc/sys/vm/swappiness
>> because...?
>
> Packaging concerns, as I mentioned before,
>
> On Mon, Nov 01, 2010 at 08:52:30AM -0400, Ben Gamari wrote:
>> Ubuntu ships different kernels for desktop and server usage. From a
>> packaging standpoint it would be much nicer to have this set in the
>> kernel configuration. If we were to throw the setting /etc/sysctl.conf
>> the kernel would depend upon the package containing sysctl(8)
>> (procps). We'd rather avoid this and keep the default kernel
>> configuration in one place.
>
> In short, being able to specify this default in .config is just far
> simpler from a packaging standpoint than the alternatives.
>
Hmm, then, can't we add a sysctl template config/script for generic
sysctl values ?
Adding this kind of CONFIG one by one seems not very helpful...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
