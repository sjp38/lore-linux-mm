Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id A71AC6B0044
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 03:42:08 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so204605obc.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 00:42:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350629202-9664-9-git-send-email-wency@cn.fujitsu.com>
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com> <1350629202-9664-9-git-send-email-wency@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 19 Oct 2012 03:41:47 -0400
Message-ID: <CAHGf_=ohk--=AKesgm+3U2qsSvjaVFBXn9c1KDru40GEpbM7gA@mail.gmail.com>
Subject: Re: [PATCH v3 8/9] memory-hotplug: fix NR_FREE_PAGES mismatch
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, Christoph Lameter <cl@linux.com>

On Fri, Oct 19, 2012 at 2:46 AM,  <wency@cn.fujitsu.com> wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> NR_FREE_PAGES will be wrong after offlining pages. We add/dec NR_FREE_PAGES
> like this now:
> 1. mova all pages in buddy system to MIGRATE_ISOLATE, and dec NR_FREE_PAGES

move?

> 2. don't add NR_FREE_PAGES when it is freed and the migratetype is MIGRATE_ISOLATE
> 3. dec NR_FREE_PAGES when offlining isolated pages.
> 4. add NR_FREE_PAGES when undoing isolate pages.
>
> When we come to step 3, all pages are in MIGRATE_ISOLATE list, and NR_FREE_PAGES
> are right. When we come to step4, all pages are not in buddy system, so we don't
> change NR_FREE_PAGES in this step, but we change NR_FREE_PAGES in step3. So
> NR_FREE_PAGES is wrong after offlining pages. So there is no need to change
> NR_FREE_PAGES in step3.

Sorry, I don't understand this two paragraph. Can  you please elaborate more?

and one more trivial question: why do we need to call
undo_isolate_page_range() from
__offline_pages()?


>
> This patch also fixs a problem in step2: if the migratetype is MIGRATE_ISOLATE,
> we should not add NR_FRR_PAGES when we remove pages from pcppages.

Why drain_all_pages doesn't work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
