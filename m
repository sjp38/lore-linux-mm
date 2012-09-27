Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 860556B006C
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 16:17:36 -0400 (EDT)
Received: by obcva7 with SMTP id va7so2800941obc.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 13:17:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1348724705-23779-4-git-send-email-wency@cn.fujitsu.com>
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-4-git-send-email-wency@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 27 Sep 2012 16:17:15 -0400
Message-ID: <CAHGf_=qhBSvOgStSgmcKZY8qMyj_Fp=3RLMD08YM8F9NzuY28Q@mail.gmail.com>
Subject: Re: [PATCH 3/4] memory-hotplug: clear hwpoisoned flag when onlining pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com

On Thu, Sep 27, 2012 at 1:45 AM,  <wency@cn.fujitsu.com> wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> hwpoisoned may set when we offline a page by the sysfs interface
> /sys/devices/system/memory/soft_offline_page or
> /sys/devices/system/memory/hard_offline_page. If we don't clear
> this flag when onlining pages, this page can't be freed, and will
> not in free list. So we can't offline these pages again. So we
> should clear this flag when onlining pages.

This seems wrong fix to me.  After offline, memory may or may not
change with new one. Thus we can't assume any memory status. Thus,
we should just forget hwpoison status at _offline_ event.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
