Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id E9CF66B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 01:29:42 -0400 (EDT)
Received: by qgdd90 with SMTP id d90so87167900qgd.3
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 22:29:42 -0700 (PDT)
Received: from BLU004-OMC1S32.hotmail.com (blu004-omc1s32.hotmail.com. [65.55.116.43])
        by mx.google.com with ESMTPS id l33si23579155qga.76.2015.08.16.22.29.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 16 Aug 2015 22:29:42 -0700 (PDT)
Message-ID: <BLU436-SMTP188CEA4C54A9E8CDC3C29A880790@phx.gbl>
Subject: Re: [PATCH] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
References: <BLU436-SMTP2235CDFEDA4DEB534BF8C85807C0@phx.gbl>
 <1439785924-27885-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Mon, 17 Aug 2015 13:29:35 +0800
MIME-Version: 1.0
In-Reply-To: <1439785924-27885-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 8/17/15 12:32 PM, Naoya Horiguchi wrote:
> [...]
> OK, so I wrote the next version against mmotm-2015-08-13-15-29 (replied to
> this email.) It moves PageSetHWPoison part into migration code, which should
> close up the reported race window and minimize the another revived race window
> of reusing offlined pages, so I feel that it's a good compromise between two
> races.
>
> My testing shows no kernel panic with these patches (same testing easily caused
> panics for bare mmotm-2015-08-13-15-29,) so they should work. But I'm appreciated
> if you help double checking.

This patchset looks good to me after some stress testing.

Andrew,

Could we pick it in order to catch up upcoming merge window? :-)

Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
