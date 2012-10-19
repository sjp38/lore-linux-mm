Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 8AA296B0075
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 03:06:35 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so173237oag.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 00:06:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350629202-9664-7-git-send-email-wency@cn.fujitsu.com>
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com> <1350629202-9664-7-git-send-email-wency@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 19 Oct 2012 03:06:14 -0400
Message-ID: <CAHGf_=oB5bDaw4JepMuKcEUM3=GaEuy8NZb+7G4uR3=-hYh8Dg@mail.gmail.com>
Subject: Re: [PATCH v3 6/9] memory-hotplug: update mce_bad_pages when removing
 the memory
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, Christoph Lameter <cl@linux.com>

On Fri, Oct 19, 2012 at 2:46 AM,  <wency@cn.fujitsu.com> wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> When we hotremove a memory device, we will free the memory to store
> struct page. If the page is hwpoisoned page, we should decrease
> mce_bad_pages.

I think [5/9] and [6/9] should be fold. Their two patches fix one
issue. (current
hwpoison doesn't support memory offline)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
