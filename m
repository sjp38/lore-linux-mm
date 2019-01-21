Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D35D0C3712F
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 22:02:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D1582089F
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 22:02:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="GuRKALKV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D1582089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 174DD8E0005; Mon, 21 Jan 2019 17:02:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 126388E0001; Mon, 21 Jan 2019 17:02:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 014178E0005; Mon, 21 Jan 2019 17:02:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9A1D8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 17:02:37 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b16so21929768qtc.22
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 14:02:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=OJCgqsaZ+wmR6x0X309IC98tvTtpLA7MmmS/XOpDQfc=;
        b=nSFnrlrnr4RMBJWZRJ2GxL4T2Enj1SYnPGj7wT3y5aPItDJVEetMns4XU7IqxNiRsk
         pLALYz9p6cH6nYnxexfP+HeNSdIYmPLfLbp5AWgkHAgXmMDk80zL1x8U20vqV8ZkCWn3
         aoNsU1kGNruaGqzIiBFtczXdn3xvN9PM1gTxgWORKV8K/QO801kpZCzNtthXe692ACdW
         eYWmXpV6jgtaszn0lvWoUHZcJUmt6XeNE/jd9MhE/lIWG4Nh8yLRQsthlbQargvP5RBO
         hRoAq228RCm8m7vIWY3a+b6GksRis5HJhtllqa8f0X2why7RZP9WkaTb8xWJahyi6sDK
         zUiQ==
X-Gm-Message-State: AJcUukdh3BiS+ujP4+f6GSCzdIWK5sGO9LMraToRpp3hoNaLngFQHGJl
	3QLOEqBJ2xGQC0sWWZ9srRPRKgzYL/LaouPk6XO3S0aFY4rscz1JZ0mj/WR4AxdeoLUNE2hWFxS
	RysLOWyjMpG9as3IR8gdodtHRyeBNQLvJpHMiD05g8jVPtdxx5lNu7nC3b/DYtb0=
X-Received: by 2002:a0c:d933:: with SMTP id p48mr28004762qvj.15.1548108157595;
        Mon, 21 Jan 2019 14:02:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7AvkVRRyozQ4eZXWPGqTMwVGLKS5TuzwC4CRW2cJiUW/lhym4+9kwwJa5WF76O068aociW
X-Received: by 2002:a0c:d933:: with SMTP id p48mr28004731qvj.15.1548108157095;
        Mon, 21 Jan 2019 14:02:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548108157; cv=none;
        d=google.com; s=arc-20160816;
        b=WRlRkLaTIytrISRsMgnrBvN6PohPx1yEXhwKEjn+NSFi9LBT6awn4LJJK2G6+Ek+uC
         6eV91f578jT3VBhmYNmWl7T59POBFmVnAh7ZyeF/STV4Tk8DzPNzBNJcHotlj9jGmTd4
         UFAHaqm9QCajuHK2HlzYOcWiEabVdcQgHu9U15On9HXZmp2kM3DgQLsia2uEjcUjKRo6
         srVslkhAA5xQeDGaL5+0d3Sf/8zY9oIgUVcrYuhzC3wK4fT8cgakUhJz28oNWZvKrAIX
         x4XWPcZcm/mLvY/Ma52U9Vap+5nzHt+L0Z1LFCePy77rC+lPwP5Lo0+1UJfbeaqwnAYo
         gaJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=OJCgqsaZ+wmR6x0X309IC98tvTtpLA7MmmS/XOpDQfc=;
        b=rVj2z+FhITHJFkF9HI/p9gVSsfuGpoBXM0W/tHy+/Z4cWombenBXQvgrabl4phSlrn
         jmaJzMdoqf3gXwlvl5ddEmy0cKJ8FeqSLOu6BVfmKYUHdeyBiaxTEVsLxgUwz3GktQQ5
         ofTdHshqnBSDvIRlhnWW+FJG7FlQV296qHRNpoAesNsacduz44iXnusJzg6CMyOx++PU
         +3hm4YgAzmds8ZRbmOAb4GmJBQGCfzrEpQ4r6x1FkjCBHUiaIkil2JonlfUyao9kcICu
         187oG80dg9lsvguKVLZm1/gHdn4bQfsaMogJX3c7mW119ZSkZsVnuS/dqvdbPqKEkTCp
         vX6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=GuRKALKV;
       spf=pass (google.com: domain of 01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@amazonses.com
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id b6si2305201qtq.62.2019.01.21.14.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Jan 2019 14:02:37 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@amazonses.com designates 54.240.9.34 as permitted sender) client-ip=54.240.9.34;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=GuRKALKV;
       spf=pass (google.com: domain of 01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1548108156;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=OJCgqsaZ+wmR6x0X309IC98tvTtpLA7MmmS/XOpDQfc=;
	b=GuRKALKV2VCcr4jAbByx0u0oiNeiB4CSPat1WTFMtNriM8UmrZ/OntXWBFDYRvMe
	elpi405dUNq+OuDa8zhLri7SlJ3XFdTVKrMt1Z8CWIRgEu8L6W2+Q8ypTqiG8N7yfcN
	EESFVbiUwIJPQprgTCvW5t0Ar0FRiBrf/RmXa1ik=
Date: Mon, 21 Jan 2019 22:02:36 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Miles Chen <miles.chen@mediatek.com>
cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org
Subject: Re: [PATCH] mm/slub: use WARN_ON() for some slab errors
In-Reply-To: <1548063490-545-1-git-send-email-miles.chen@mediatek.com>
Message-ID:
 <01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@email.amazonses.com>
References: <1548063490-545-1-git-send-email-miles.chen@mediatek.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-SES-Outgoing: 2019.01.21-54.240.9.34
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121220236.uvdpuKrvMiOuzaq1uS4jte1kkGM7RN5o0eoPh0wX2gA@z>

On Mon, 21 Jan 2019, miles.chen@mediatek.com wrote:

> From: Miles Chen <miles.chen@mediatek.com>
>
> When debugging with slub.c, sometimes we have to trigger a panic in
> order to get the coredump file. To do that, we have to modify slub.c and
> rebuild kernel. To make debugging easier, use WARN_ON() for these slab
> errors so we can dump stack trace by default or set panic_on_warn to
> trigger a panic.

These locations really should dump stack and not terminate. There is
subsequent processing that should be done.

Slub terminates by default. The messages you are modifying are only
enabled if the user specified that special debugging should be one
(typically via a kernel parameter slub_debug).

It does not make sense to terminate the process here.

