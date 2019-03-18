Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F30B6C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 18:12:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 925002133D
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 18:12:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GEe32eB2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 925002133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F37AA6B0003; Mon, 18 Mar 2019 14:12:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE5636B0005; Mon, 18 Mar 2019 14:12:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD4A16B0007; Mon, 18 Mar 2019 14:12:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B65596B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 14:12:32 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 23so15323116qkl.16
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 11:12:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=uvMhFpTyg9wzNJYyCVyIrkVvZfj/hFZELXMKCxlWuo4=;
        b=gIACKMq7BIVCW5u3puInQLZOhzGJj7EY9pCsj6pioKIIR2DptJJ05XUJiSUbMEchQj
         JhnPBP6riY2sRezduSBxtu1rexg9Bcgu6KcLuWcaUotmqV2cXHQtryCZrF7zMX8pymrI
         WZkT/caj9EuNrMIj5dWuLHehwR98q3ifG87F3fpyQgFcxW+i0XfQQ3+ydC3wL28Norm6
         RzMqWBl5wHg7iOmdWofUj0BkDnP8ke0OCqeCuqUGcEi6xjindQRUMSrYOgNpbWZsBjQb
         rMVaLmL/mDNGPzIQi5TkQvOT/xHkXFSRKBDGdigDISAVQbgVSPhWBSMg20rkoIGtZGt6
         p89g==
X-Gm-Message-State: APjAAAUWKly5dMfWU1qAbsUKaymDPQ6kepQDFIpFrUD3yh6ztvlsSvNV
	2HQUGWZ9oq6ShcFJlDXphV8DrZxXRc7HNvzGD1UT3CamEf6kd6HRzh4w95HX5AnMSyseRR5/zyG
	oaMMxFcNKlG5Q5sotJaCos1Y8twVEC54Y5UAMTtKCNddBqRgwn002W6V/9p9FMIMIWg==
X-Received: by 2002:a37:a80d:: with SMTP id r13mr13572669qke.85.1552932752485;
        Mon, 18 Mar 2019 11:12:32 -0700 (PDT)
X-Received: by 2002:a37:a80d:: with SMTP id r13mr13572614qke.85.1552932751539;
        Mon, 18 Mar 2019 11:12:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552932751; cv=none;
        d=google.com; s=arc-20160816;
        b=lVkJPxP7GphEDLlBpBcXbR3Fph3ikPVL9cOrUpeFp428fFcvMOygbvpcxsVG8UumOR
         mvxZIjASiLiYtdRz03awZ4jJ0dQEATHp+5wh7q+wBtVAj5QzY3NrJ1x/cDB7R6qEXZUX
         DtL2Rm6oVxkllV69sz8wsbxYxtYKn5bQuRSHKu2GG6XngTMdB2ezRReY7cwmSqqtcTV3
         4K6zgERCflhF2KICUOn8Kbj0k5yN9SCC39E6T1ZAqU5MxmPDEDe2sRgy32E/9uKvDKra
         kW4MppHKMK2I2M7RYOYn8xJYSaEaKHkHgqL+cEwgh3DSWXhGHbJOc6RvBL0bc57K1oub
         h0hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=uvMhFpTyg9wzNJYyCVyIrkVvZfj/hFZELXMKCxlWuo4=;
        b=aXgrHnI4ZVTC+xEUFtvap122WURc7/KXeitWqLI9Im7Fijgr2tfGwLDVoOhXTrEEFW
         AwukA1b8MKDhzsMPRRnvriRosSIQmyenpwAjV1ThwDgMGC2CvRE87yQAJsrl+4l6hbBA
         Yl9SvGSvnjqvctq4oa69fcGe0j60f7Wt79xm4VULSA6dW6sclKAg3Q68DyJCheXMkiCC
         F1eylk6DzR/0VUkjxpBGGTRAy0uDWpDWDh9v2rTb9vu63XLyFOWCkkPGnZdTJUgnKN8A
         ab/QspCV35UTNyQdva7zpmJXUKq6vCdAEmFJzM37f0HbopgRynQ1O7N6SjJW9+yZxAaA
         KRfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GEe32eB2;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r29sor12833261qtb.19.2019.03.18.11.12.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 11:12:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GEe32eB2;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uvMhFpTyg9wzNJYyCVyIrkVvZfj/hFZELXMKCxlWuo4=;
        b=GEe32eB2Qo9Uz3cvHysv7tf34APWlHmfToWHGodpCSanwqC4cPtuApFwilpFx0Pi2J
         h+T3ltpOqMNQ998oD3GOAnt+BnKg36yYy9NWQT6QN9n+9nk9yAqGeCx4mYvh/tU5pfQL
         EqL5iC2gx7ajjD1wT5OtMRvswLl6exOyUC+0OpYi8CqyKg+kzHhcIG1n58Q4SBq5rXJ2
         dehwxbrfBM8pthmQf4DDMY3oWC2oDqAFh4Mpr6qSFNlga6B/i8gF1bRatPDqh5owjCDS
         lNYwiNuPTdnV5mteILv4Algan2pqlV61QcrgMEpkjAbnOJV9EGrpWpsvjKhyWZnrh/r4
         pCgA==
X-Google-Smtp-Source: APXvYqzMCyTd4hQIcmlwJjhaPdCSxvlPbS2xfwuPEUKGfQF4Xmf/CvM87NnP0NzUGZhacIo3cPYQui8bWi8xGYMnb5E=
X-Received: by 2002:ac8:3629:: with SMTP id m38mr15114307qtb.369.1552932751043;
 Mon, 18 Mar 2019 11:12:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190315160142.GA8921@rei>
In-Reply-To: <20190315160142.GA8921@rei>
From: Yang Shi <shy828301@gmail.com>
Date: Mon, 18 Mar 2019 11:12:19 -0700
Message-ID: <CAHbLzkqvQ2SW4soYHOOhWG0ShkdUhaiNK0_y+ULaYYHo62O0fQ@mail.gmail.com>
Subject: Re: mbind() fails to fail with EIO
To: Cyril Hrubis <chrubis@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, linux-api@vger.kernel.org, ltp@lists.linux.it, 
	Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 9:02 AM Cyril Hrubis <chrubis@suse.cz> wrote:
>
> Hi!
> I've started to write tests for mbind() and found out that mbind() does
> not work as described in manual page in a case that page has been
> faulted on different node that we are asking it to bind to. Looks like
> this is working fine on older kernels. On my testing machine with 3.0
> mbind() fails correctly with EIO but succeeds unexpectedly on newer
> kernels such as 4.12.
>
> What the test does is:
>
> * mmap() private mapping
> * fault it
> * find out on which node it is faulted on
> * mbind() it to a different node with MPOL_BIND and MPOL_MF_STRICT and
>   expects to get EIO

It looks the behavior was changed since v4.0 by the below commit:

6f4576e3687b mempolicy: apply page table walker on queue_pages_range()

The new queue_pages_to_pte_range() doesn't return -EIO anymore. Could
you please try the below patch (5.1-rc1 based)?

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index abe7a67..6ba45aa 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -521,11 +521,14 @@ static int queue_pages_pte_range(pmd_t *pmd,
unsigned long addr,
                        continue;
                if (!queue_pages_required(page, qp))
                        continue;
-               migrate_page_add(page, qp->pagelist, flags);
+               if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+                       migrate_page_add(page, qp->pagelist, flags);
+               else
+                       break;
        }
        pte_unmap_unlock(pte - 1, ptl);
        cond_resched();
-       return 0;
+       return addr != end ? -EIO : 0;
 }

 static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,


Yang





>
> The test code can be seen and compiled from:
>
> https://github.com/metan-ucw/ltp/blob/master/testcases/kernel/syscalls/mbind/mbind02.c
>
> --
> Cyril Hrubis
> chrubis@suse.cz
>

