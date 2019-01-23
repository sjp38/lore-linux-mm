Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04AA7C282C0
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 22:57:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B37D5218A2
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 22:57:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="q1CTvIaN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B37D5218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5375A8E005C; Wed, 23 Jan 2019 17:57:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E5988E0047; Wed, 23 Jan 2019 17:57:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D4D58E005C; Wed, 23 Jan 2019 17:57:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0828F8E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:57:48 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g13so2543803plo.10
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:57:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:subject
         :in-reply-to:references:message-id;
        bh=WTXgQ9idwZe9zME2L7X5s/Amurdep+lolQuIEf9tkTQ=;
        b=gOsIQUFXQUllv5JJQZz+laP2NQSjijsgbYcITOKuVjMAfN3R1ec6yMW0hpre0XjrN9
         HEofuWicUUxt7JUXcMVMPkHu67wYchz60xa9++jAS6exZbz+v0IA5+HBiS1N+kBOanBL
         k2ytB+GVKaeqJDD7aL1X3SMwVR/Mn/dMDT7YthBottZy7UdXsHdgWJaA57g/H6J96uRy
         mcVtAf5IktKRrphlt/qGwDJMMYxMf1ub3QoLgDezr1lm6jH0SBEJx1p+w2wLqjthSHnF
         n2EPGUDk8NNiKF+mpXw/tLJY89Cy9weYwXxmlWlhu5uS27FUm/CTk2LAHdRQe+GbyoFZ
         LSRA==
X-Gm-Message-State: AJcUukeps0C25g0Y23xL0Qz42i8G0Bj06vzLBcapKTzPy+mw8TPzTMdf
	QvQh0w5ZmyZBkBDyWKV03mQ6nboJ5HIBRn0l7frjYfR88pGWtCeaPGd2scv3AlGvxnCwL4QFf99
	Ng3dQeURbN8p0odk2nDt2Tml3YceuzvXhctqs6dI/UFQXMaSha6/h2tM0PX24bNoEAw==
X-Received: by 2002:a17:902:8d95:: with SMTP id v21mr4154001plo.162.1548284267580;
        Wed, 23 Jan 2019 14:57:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4QNHpbXLOxbCRo0oDgGH+O4wT/9DUmnxJjLepMQLS+iXbutj4ECnk38YMtBWt10AVJDF9J
X-Received: by 2002:a17:902:8d95:: with SMTP id v21mr4153972plo.162.1548284266951;
        Wed, 23 Jan 2019 14:57:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548284266; cv=none;
        d=google.com; s=arc-20160816;
        b=kzFhk+0qmyGm8QE2PNs4FpMtGtg1LPM5cXGsSQtw2zqK/0OZoLNuv7Cw/NB7J+Mo45
         vB5t1IRicGsbRVHh/L9Hg2aEkZt6+8L+58FeG79F264TNlzIyFrIGmEI2fwgK8J72JIs
         mj4V+eeFKua12LLQztZMBMIVT3aykJ7hVop5ypNcqzUGb2CvhMYzGgxb8KwxOZU9sIRJ
         p5uxWrpoVONCujEcbxsM4S7NavGeQ0JzGtCgZ+SKZD51HfETIL7f2wZfqbF93N5CEzxh
         jHnP9Bj5/A0jsm7oM8dSW+jv4kb6ZN62/Z7lj0aS/cmGuxLvfaitQ+tMMXjFOn2RWCPw
         xxRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:to:to:to:from:date
         :dkim-signature;
        bh=WTXgQ9idwZe9zME2L7X5s/Amurdep+lolQuIEf9tkTQ=;
        b=hwguFf0qyqdKGLlqBo2T4beem9s6pyox+Kivcg8EhYcpwDhSIhAM6DJqgP0jl6vDg0
         l1i1F5kQ20ObAoiDG4YiFzEibE2yNdrlcFkkrdpDl47XQxO98rZQfRAlaGQMsFWlihY1
         euMP54qwDmQm2P9R6AJ6vCsxJVdlmRG+iJHmSA/6Az7VJTKC43uS1ujSJWG54gGm3K3S
         U3INfxIvLlyZJlnzlcYTRdrswo7NQe0xg0WBPVhtBqaOqRJgIAIVLmdFj0f9p3Xw19EH
         u6AFP/gCCAszBay5pXblOcSBgkRtoWSLDKpMrKeS11GdjmwTAFkcX0Fo+PhnABmA7H1h
         EsSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=q1CTvIaN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k20si19123583pfb.215.2019.01.23.14.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 14:57:46 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=q1CTvIaN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5B3DF218A4;
	Wed, 23 Jan 2019 22:57:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548284266;
	bh=eLhl+DZ3RcO04/6ZQTi1AgHbsUblNaKRAUs8VoYT6Nk=;
	h=Date:From:To:To:To:Cc:Cc:Subject:In-Reply-To:References:From;
	b=q1CTvIaNz0k32U+v5FgAluj11VTEywKVaybjHpVHZxZ5JgYXtvJvaZhtD6raUuZKE
	 h/Rs300A9gjq1tsCBCaN+sWCPeu7XOo4TTkkAXU1UqWDV3EDkWLFY1ACU69H9/PqVE
	 St2t9itk3k+qsYoas2ZM8NWHPUfccikHWLxUbH2U=
Date: Wed, 23 Jan 2019 22:57:45 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Sandeep Patil <sspatil@android.com>
To:     vbabka@suse.cz, adobriyan@gmail.com, akpm@linux-foundation.org,
Cc:     linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
Cc: stable@vger.kernel.org
Subject: Re: [PATCH] mm: proc: smaps_rollup: Fix pss_locked calculation
In-Reply-To: <20190121011049.160505-1-sspatil@android.com>
References: <20190121011049.160505-1-sspatil@android.com>
Message-Id: <20190123225746.5B3DF218A4@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190123225745.TSlgRxoNfexwifvzDqRN5hSLYhBIoP38IZbqscYyifI@z>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 493b0e9d945f mm: add /proc/pid/smaps_rollup.

The bot has tested the following trees: v4.20.3, v4.19.16, v4.14.94.

v4.20.3: Build OK!
v4.19.16: Build OK!
v4.14.94: Failed to apply! Possible dependencies:
    8526d84f8171 ("fs/proc/task_mmu.c: do not show VmExe bigger than total executable virtual memory")
    8e68d689afe3 ("mm: /proc/pid/smaps: factor out mem stats gathering")
    af5b0f6a09e4 ("mm: consolidate page table accounting")
    b4e98d9ac775 ("mm: account pud page tables")
    c4812909f5d5 ("mm: introduce wrappers to access mm->nr_ptes")
    d1be35cb6f96 ("proc: add seq_put_decimal_ull_width to speed up /proc/pid/smaps")


How should we proceed with this patch?

--
Thanks,
Sasha

