Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id AF3D96B004D
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 21:07:50 -0500 (EST)
Message-ID: <4EEAA7CF.8010006@parallels.com>
Date: Fri, 16 Dec 2011 06:07:11 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: linux-next: Tree for Dec 15 (memcontrol)
References: <20111215191115.fd4ef2ab8fa11872ea22d70e@canb.auug.org.au> <4EEA8693.8020905@xenotime.net>
In-Reply-To: <4EEA8693.8020905@xenotime.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/16/2011 03:45 AM, Randy Dunlap wrote:
> On 12/15/2011 12:11 AM, Stephen Rothwell wrote:
>> Hi all,
>>
>> Changes since 20111214:
>
>
> memcontrol.c:(.text+0x31f9d): undefined reference to `mem_cgroup_sockets_init'
> memcontrol.c:(.text+0x326dd): undefined reference to `mem_cgroup_sockets_destroy'
>
> Full randconfig file is attached.
>
Hi.

Thanks. This one is also fixed by one patch I am about to send.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
