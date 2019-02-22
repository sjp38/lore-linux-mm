Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D8AFC10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:22:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CCB8207E0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:22:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="b267o0z6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CCB8207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9777E8E012A; Fri, 22 Feb 2019 13:22:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9001D8E0123; Fri, 22 Feb 2019 13:22:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A0C58E012A; Fri, 22 Feb 2019 13:22:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4EDA18E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:22:55 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id h73so1956251ybg.8
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:22:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/1iRUWXUez0vQmzuA6ScUoUTtthAjz8oJPlMkoBcgCo=;
        b=FXgmLSwH7MUrkYiVSRfP2zi0HW2L4UN1HodRMOew8l72atu2S6TeN0htDcUMD4vmpA
         zWVLuqtEjpZ18MqsdEFqrwiSY0l6xCXimVj30aKVNmRwypnorNeLTmc45MKneUz9N86r
         qFHPuB1t+g7TMLVYD7ZrECDH4vmWr9AyKULU5pbbJIOeh0aTfm0ZERDB/EMCWAT8zU6A
         Sa2BoAJSeCMjqKtlBt5FPJc0aVDcRTfzA5Jz3OKxLbqaukaCk3siksF7jB0wHnqmEiIm
         nOOLPmWoPsqBV1lps2NCgkblZsIU+HqT+49W2E1bpM3kVUtJJFEU5Q5UibCTUPcPx58u
         1Yng==
X-Gm-Message-State: AHQUAuZHFU2AE7T4cVSsHhMlWRf8VbHNSzUYIQlRA4+nHgPdEIArJWvw
	Zu+JwegYlvK1U5jA9Wayj11zqAxwgfy5mr5uJS8XuKktjPHsSGT4/GoXn1Vg+0jcDAVtsM3bClG
	2HSWT3kadSSo4T2qYPbrIrE+o9FiEr6xlPTYJuQyxiSQBVd71LY3pu3rOz6q0GtUVBKLFUTEBUD
	J7J91G1GJBW802aD0hMcpwGnBugyfzcJtPu6Gj8sPAZiOuF1Kg+C/710B20oE1RJY1qQvU49Bxe
	4F+fX+XQV2dSK3F0OAi4XoBQrWN9G02shrdOUWaNgpSlXpxPtONBcpOSvbWhsyF0ZsWce6qdqOJ
	tjPvvaFpxrubIaen7wASoMXgVLDBKq+aUCLMle4uCEZYSalzCxNwNrWD9HqSnuxa+R3O8+NAwfc
	p
X-Received: by 2002:a25:9703:: with SMTP id d3mr4485408ybo.407.1550859774993;
        Fri, 22 Feb 2019 10:22:54 -0800 (PST)
X-Received: by 2002:a25:9703:: with SMTP id d3mr4485356ybo.407.1550859774241;
        Fri, 22 Feb 2019 10:22:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550859774; cv=none;
        d=google.com; s=arc-20160816;
        b=u4rq3jACKZmgyvl5wWoGhMxwRXR2p64S9jmAqgfglvxrdgEH4i2UWbxeWJkrNliANS
         2wq4NT09hw+YmIcVY83VrUchd8z2KYdV18GC9j9ZzJ3ev/wSjIgKwOMAuasjQkVa+OS6
         WGBojjSqwLRDi8MKaI8heBl7Rq3HixqJhBAb5krwh42CICsK5cMv1nVdem5rmxWaPt+X
         lzkZ2/Xhj5yt/AuAlUPys0KOrsIRkof9gEx3x1/dEkqz1hUt/1/IusGVSriKGmsEgrIK
         IdWG4Kntq4HwDwpeBrOyqpZrB8g57NYLrVNzbB0YOvt0I2MdEamS0TrcqDA4vbU5Asnd
         Tx4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/1iRUWXUez0vQmzuA6ScUoUTtthAjz8oJPlMkoBcgCo=;
        b=U15603HVDiu2ifZgyxzoQ+LeB92z4AJJwOKvdsVv7ug/7DhgvAUyw51onHYiizOPGJ
         Pf9JBgH5Wd70ScyneuVbmowR5w2octZeXHmiQKP5SX5s0NhxpNPPBQke4wcsx25o9lAQ
         moevJYKBTZPgGsbMG+JEply/cxB9A2JA1kKkT6+riS7XMa5MD19/DkFx96AGsKJIjAxo
         ea0uvryV8sU9HPKympnXEQo5RhYR1Utm/eFjqeL38pWpfK4z8HhCjRBSPEHD9yuTJjpm
         XUnph+6seatfXRK90ajop90Cb4eTvSBAeTDchYFsGIktQfOgSkQ1efvI9wyEkRFeWqz+
         Ufng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=b267o0z6;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l73sor442423ywc.64.2019.02.22.10.22.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 10:22:51 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=b267o0z6;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/1iRUWXUez0vQmzuA6ScUoUTtthAjz8oJPlMkoBcgCo=;
        b=b267o0z6qksczZ6tdLwpa3oMpBghC7VNreLZWEEy860EODd2+i/QjS4nWyY/ryDODy
         a5G8IZp8wvWZSWhb7LkpNdYs8nPu3EkOMlFPeqdRA++vk8m1TL08DMGGvBd6ZgP9Rpca
         6uBxZmBrK0rW0yNb2CK8KhQs3FNIRWoyUwECysD6/T4pXlFsnJTz6wcq8L5GoBjcEu7I
         RoN+qZym0HIiSVeQtM0NP3F50AmXJmjmn609rEXS5ph0WTJkbe8D0l5DG8rP0GWSIYfU
         3F7gjmpDG5rf9TUjQfVAHmOLn1pXQ6iCoXcwdNB7bCIG/6Kbwc3dgPl6o4khb+jF1Z84
         fbSg==
X-Google-Smtp-Source: AHgI3IaeDDfPbp7vXQTiAzbg0tyYv6REAy+eU0RB6B1ee5L/C1zIpSF2uD275SBiZWz5/J1nf8/SGg==
X-Received: by 2002:a81:36ca:: with SMTP id d193mr4536619ywa.388.1550859771539;
        Fri, 22 Feb 2019 10:22:51 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::1:cd3d])
        by smtp.gmail.com with ESMTPSA id c124sm683685ywe.12.2019.02.22.10.22.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Feb 2019 10:22:50 -0800 (PST)
Date: Fri, 22 Feb 2019 13:22:49 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 5/5] mm/vmscan: don't forcely shrink active anon lru list
Message-ID: <20190222182249.GC15440@cmpxchg.org>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
 <20190222174337.26390-5-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190222174337.26390-5-aryabinin@virtuozzo.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 08:43:37PM +0300, Andrey Ryabinin wrote:
> shrink_node_memcg() always forcely shrink active anon list.
> This doesn't seem like correct behavior. If system/memcg has no swap, it's
> absolutely pointless to rebalance anon lru lists.
> And in case we did scan the active anon list above, it's unclear why would
> we need this additional force scan. If there are cases when we want more
> aggressive scan of the anon lru we should just change the scan target
> in get_scan_count() (and better explain such cases in the comments).
> 
> Remove this force shrink and let get_scan_count() to decide how
> much of active anon we want to shrink.

This change breaks the anon pre-aging.

The idea behind this is that the VM maintains a small batch of anon
reclaim candidates with recent access information. On every reclaim,
even when we just trim cache, which is the most common reclaim mode,
but also when we just swapped out some pages and shrunk the inactive
anon list, at the end of it we make sure that the list of potential
anon candidates is refilled for the next reclaim cycle.

The comments for this are above inactive_list_is_low() and the
age_active_anon() call from kswapd.

Re: no swap, you are correct. We should gate that rebalancing on
total_swap_pages, just like age_active_anon() does.

