Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 9F6636B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 17:10:14 -0400 (EDT)
Date: Mon, 29 Oct 2012 14:10:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 4/9] clear the memory to store struct page
Message-Id: <20121029141012.4c1c2b07.akpm@linux-foundation.org>
In-Reply-To: <508A5B66.7000309@cn.fujitsu.com>
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
	<1350629202-9664-5-git-send-email-wency@cn.fujitsu.com>
	<508A5B66.7000309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

On Fri, 26 Oct 2012 17:44:06 +0800
Wen Congyang <wency@cn.fujitsu.com> wrote:

> This patch has been acked by kosaki motohiro. Is it OK to be merged
> into -mm tree?

I'd already merged the v2 patchset when you later sent out the v3
patchset which contains some of the material from v2 plus more things.

I can drop all of v2 and remerge v3.  But I see from the discussion
under "[PATCH v3 6/9] memory-hotplug: update mce_bad_pages when
removing the memory" that you intend to send out a v4 patchset.

This is all a bit of a mess.  Piecemeal picking-and-choosing of various
patches from various iterations of the same patchset is confusing and
error-prone.

Please, take a look at the current -mm tree at
http://ozlabs.org/~akpm/mmots/ then come up with a plan for us.  We can
either add new patches or we can drop old patches and replace them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
