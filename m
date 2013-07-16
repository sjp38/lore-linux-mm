Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 70FB06B0032
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 21:49:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 81A613EE0AE
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 10:49:00 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 738B745DE4F
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 10:49:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E24645DE4E
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 10:49:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CEF21DB803B
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 10:49:00 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0267C1DB802F
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 10:49:00 +0900 (JST)
Message-ID: <51E4A660.7030804@jp.fujitsu.com>
Date: Tue, 16 Jul 2013 10:48:16 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: migrate vmalloc area for memory hot-remove
References: <20130715163701.GA16950@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20130715163701.GA16950@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: linux-mm@kvack.org, tangchen@cn.fujitsu.com

Hi Vasilis,

(2013/07/16 1:37), Vasilis Liaskovitis wrote:
> Hi Yasuaki,
>
> in your memory hotplug slides at LinuxCon Japan 2013, you mention "migrate
> vmalloc area" as one of the TODO items (slide 30 / 31):
>
> http://events.linuxfoundation.org/sites/events/files/lcjp13_ishimatsu.pdf
>

> can you further explain this problem? Isn't this case handled already from the
> current page migration code?
>
> Do you have a specific testcase that can trigger this issue?

This item aims to increase removable memory.

When we use memory hot remove, we need to use ZONE_MOVABLE. But the use of
the zone is limited. The zone can treat only anonymous page and page cache.

So I want to enhance the zone to treat vmalloc area. But currently there
is no patch.

Thanks,
Yasuaki Ishimatsu

>
> thanks,
>
> - Vasilis
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
