Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC84EC004C9
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 22:19:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A094D206DF
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 22:19:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gB84Kd2j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A094D206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38D1B6B0005; Wed,  1 May 2019 18:19:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33E786B0006; Wed,  1 May 2019 18:19:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22BEE6B0007; Wed,  1 May 2019 18:19:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 03FCE6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 18:19:28 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id g8so253213otq.6
        for <linux-mm@kvack.org>; Wed, 01 May 2019 15:19:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=FN1Aei3JIdWcMUvV6pZNdsfhJ8LlZcWUJF6R7xXR4Rg=;
        b=pjfkqL+3N7nqom3hciWOB1e+0aZnCuro65UAu9wgPhGDhiRa6KE4IFaWkbecHI/VSa
         ITubZSwnoIu4THIk6cefluOqbtRZcTnAveY8B5SGPszOa7EgCPPkk0xDZ6rbAlzaPygd
         0clkOjBFykaoTciBi5xl8bK5oI5LvDHBXckSCaQdSaqHJsZyzboX8IkHWnjPqo8A0mks
         hFOgy1emo3RhBzrFNc4zN9mDZtyi0yQfVayDTpBGhoTe1+miNAZdMTieMKttibl70/TM
         yNvaL31dg9CCNRzT66E7JyOo7JvqUG85pboyhbPSMnEV3V94NJppKANfnxhju2Y+IoXw
         SFIA==
X-Gm-Message-State: APjAAAUATfPZfs8UUbbF64cueD/pO/l/YnaciSsNVQzqNwO097nKaC0b
	kymziCXOpdzOg9Rw8KOKdBzGgQovzrI6TWHlj08T9z2hlip4iDUcaZiYnBGXVN7GLnPG9QWSLyk
	vEZhTht+ioT7YRAfzg8FFTMboezmuGjUFg6WSy1iDikz6e/iaeevyI3c2deMYbrYpMg==
X-Received: by 2002:a9d:740d:: with SMTP id n13mr227608otk.291.1556749167647;
        Wed, 01 May 2019 15:19:27 -0700 (PDT)
X-Received: by 2002:a9d:740d:: with SMTP id n13mr227580otk.291.1556749167156;
        Wed, 01 May 2019 15:19:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556749167; cv=none;
        d=google.com; s=arc-20160816;
        b=kpcV5oLQotqqsEhwfi4XgqzR3hEv5b6NI7Z/dz0U6rDPmf5WChrVIRNJLzfzn0M7L5
         QPLRu1QA645isww0Yr72INQJVM574dhau8rpk2mfjzeWckcjKAHu5+F0UPUnrSotHEYr
         +XhzPclDoRAuZvoFGkWA6D+xNZP3iP6x0W7sZPkpvRttA2MoXMs86o7iRUx8et+PJNed
         4N6ZuLuSLLpavQG3gl+ADc3qI0L9u0TScrl6rPHwHKooLQWK4PlXKj2SJSpRo9DU9wtQ
         KcgnKFAkJlnUxYS+i3/TOnwpWPI0IZxAz0ZyjXkmEzjY3A8dKKNbbbNoit5xh+CVhmnd
         l7SA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=FN1Aei3JIdWcMUvV6pZNdsfhJ8LlZcWUJF6R7xXR4Rg=;
        b=FfRgKeSHWdwZG5B78vG8nUDzxN222aeLh2be49F6Rt4b70LEjfTG+pSg2eI7xVXvll
         c1ubg++8Nlvkrrz0FQc8W1CItprsn0ivnnXp0bnULLeb9YXg8ouaPltnV0wwbvUy/rdo
         2rRjWOvVvWS8qF6p5J2S8B1Sv+wl6rF5a0cYZHNedaDY6x5jUzNJT7jF8ecZZkHyvr+/
         Dx20XyHZD950O59RU33awEhJMWDB3cq7xTACK5E+vMgTU8kMGLBawiREbTlWBBYLrKKW
         a1ZZs8H48M5H5wcuV+tIx0bUSX0tO1lLhvVpHIcHQ9WnjWlWkGOnuMdT/GoDZg7zRCM6
         CxHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gB84Kd2j;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l184sor11625020oia.51.2019.05.01.15.19.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 15:19:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gB84Kd2j;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=FN1Aei3JIdWcMUvV6pZNdsfhJ8LlZcWUJF6R7xXR4Rg=;
        b=gB84Kd2jkRiVtjdVji4hGs/gVsYEge35Rov52wADHOGJPFN0N3dzITJDFjmBSmZfa4
         dDW2Qz3TNE+MTmU5lgBMtKSho0UEdn6Q31zsO3VwzBDIlMFtjb1zlyAc5qkibsJjF5tY
         F0igVAlgUsoutwvqe2hQK5PDU2Fj6/GxgF4sbeyBPADgK6rS7CpEjXK7pHioTdLjfbb5
         q6QF2OCzVHrGzKqmnuD+O5zBz+QJja68cODdnV+c5256Yqf0jra7LxsXYaL912bjawMK
         ZFWKCwFXrlFbIZqcSAD34cY3ox9a299AyjY/2cS5cZ43VxfAOyfGOv/Do9HItZLjYT9o
         b9jg==
X-Google-Smtp-Source: APXvYqz37+A3X/ti5n186PrmPylDpRcQbfyrYOKdQhkK7g3shYNip/5P3d1uKDocAbS17IjWlQCIbOvgQ0j9hB6a7IU=
X-Received: by 2002:aca:e4cc:: with SMTP id b195mr414914oih.39.1556749166727;
 Wed, 01 May 2019 15:19:26 -0700 (PDT)
MIME-Version: 1.0
From: Jann Horn <jannh@google.com>
Date: Wed, 1 May 2019 18:19:00 -0400
Message-ID: <CAG48ez3C11j5On4kqwSBCZGtpS5XMohwEyT_2ei=aoaTex7D9Q@mail.gmail.com>
Subject: get_user_pages pinning: 2^22 page refs max?
To: Jan Kara <jack@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.008032, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Regarding the LSFMM talk today:
So with the page ref bias, the maximum number of page references will
be something like 2^22, right? Is the bias only applied to writable
references or also readonly ones?

