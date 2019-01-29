Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A827C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 226E02175B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:12:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 226E02175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8029F8E0002; Mon, 28 Jan 2019 19:12:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B2C08E0001; Mon, 28 Jan 2019 19:12:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62DAF8E0002; Mon, 28 Jan 2019 19:12:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E80E78E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:12:29 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id p65-v6so5305902ljb.16
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:12:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:reply-to
         :subject:to:cc:references:from:openpgp:autocrypt:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ZbnSJMurLj8BNQYytJBUO+GTsAvTERR77Xowzcjxf6U=;
        b=FpiaI/aZd5bXLoHBa34yZgnM7QqJxFhMDBZIYBj0pRF7PYBrsDruN0GgfzMWHvLVkP
         edSOcK9WZ/G9gxWzhaElzWn7EOStz3XgI0OrUK2FUf1wqZMS8GTWc83DoplO5vRPzbIb
         PBtIAzXh7VVLU3+4h3SEGIugfu8QAmm7djjEhA16EL+KyJgv9vribMlB8nMEcDKymuR1
         KftNK0xNeOmkaAqKou0YXe28hZBs5ynqbn28qVEjY9gl2alcyYVaNHbt7YhjJIGBbTh2
         6/HcanJ23s/C1beJ8hIAAXspBJr1qC2JXIsZKL2/GPmU0kxMj9rOJtInCopjDKG5YJ8L
         vN6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of a13xp0p0v88@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=a13xp0p0v88@gmail.com
X-Gm-Message-State: AJcUukcGxCRYXkpEup6jQDiMcNv0jC/eMme8S4JAyRQrYzssa8USL5+L
	1A/ptbPfPRYELpx2MkYyYfulSCEV+NZk1PjB1d2M+LC19v9IB0U3HtzRsffK2uiX40ivzFPieZg
	a08UZGcQX4Ee2eN/yCs67PgKeDpoyogr/UNoZntm53H7HlouPDyq3JRyuK4MjJJb6Vy7x5O+Dvh
	YGumaoUr0nGuBtnWoldNTEbyN+r1Z48CyIwQilnuLV7Dqz+1SijOasuRXWLODNHkn7Ztff1qFTO
	iVG+PaB7vuL6Z9/BN1BuBJ28m+jsWMqqVvRTPzR0ykOFuLEzZfpV9M3Q1vUGmfV2vg0pZHBZqkc
	1EEJ/yFl9HDok2pqYaSAHfd9PAAC48O4KnaYss/xvZCqN2akX6DS7MK/avGS24wGp7b9VBUq8g=
	=
X-Received: by 2002:a19:5d42:: with SMTP id p2mr17727492lfj.83.1548720749251;
        Mon, 28 Jan 2019 16:12:29 -0800 (PST)
X-Received: by 2002:a19:5d42:: with SMTP id p2mr17727460lfj.83.1548720748075;
        Mon, 28 Jan 2019 16:12:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548720748; cv=none;
        d=google.com; s=arc-20160816;
        b=I1uK+LE177uiOqH6Dsa4NENirxhqkKbHhsFi0qku2oiJ7fw+LMQC771XDmqfKJohSm
         Lv34cgdvBSS/7q/2ISC7cIjIUcjHCvA1QWtyz12NUi0acbocceho1MFwafAJMXUkJCY+
         Yj8P46YpGCz+xvDZwH56S/wJTfbOZEfgXcusVvTH49N0oO3S52/v8Af3+VQ6lm5nn2jY
         hIV6EqBDIOAKq2mUo8FvZWd4TfeucDeUd02nGsEvX8ZV09nanAV7w4fWocULzQVcr4QH
         upmgpBH51xOQ8isJi4Ucd1NvUyeMYDtCCwKJc03NgUF9JXTT3s0GUigzBdRf8Wq7nV6/
         TYSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:reply-to;
        bh=ZbnSJMurLj8BNQYytJBUO+GTsAvTERR77Xowzcjxf6U=;
        b=XNdxwFBn6idbtGXCU2jL/7ewlJo7rc1Zkawkc1w+IjTn6Ko4HxiA2MKdLUz1HTyd0e
         ad/fWT3B03m0O3SEuX0La1oZCOUnuioIGRjND511M6NvpdSpcyOGGojJRcU22jfz3Uux
         hyj0ZCKZ+toqAQEIL/JLjN0sQfzzcwk82gNl8anQ4ErLdVjZVN+T/zsNE6J/TfQQAbmz
         1jV26M8dH7no2hggoef6RfsXyomFhPfgDLYw/5MBeZdV3qQVXaUVQ8s2R7NDWHhs29j1
         f8jQlSeXAX4v8O4/SzsSbZGuPSXq/5SiaL7JcCbcCu7kjk99mqVMmdtX7+O6SxEj4v8d
         w+CQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of a13xp0p0v88@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=a13xp0p0v88@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1-v6sor11845545ljg.10.2019.01.28.16.12.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 16:12:28 -0800 (PST)
Received-SPF: pass (google.com: domain of a13xp0p0v88@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of a13xp0p0v88@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=a13xp0p0v88@gmail.com
X-Google-Smtp-Source: ALg8bN7stDrH2CqQuY0B3RQYZuC7ccWFVr0KUPp1UnTxiXJjsgOqvC25P0WS7lOaf7LQDZ9JOZ4qbA==
X-Received: by 2002:a2e:8187:: with SMTP id e7-v6mr18527787ljg.67.1548720747585;
        Mon, 28 Jan 2019 16:12:27 -0800 (PST)
Received: from [192.168.1.183] (128-68-180-17.broadband.corbina.ru. [128.68.180.17])
        by smtp.gmail.com with ESMTPSA id m1sm3205465lfb.56.2019.01.28.16.12.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:12:26 -0800 (PST)
Reply-To: alex.popov@linux.com
Subject: Re: [PATCH 0/3] gcc-plugins: Introduce stackinit plugin
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Laura Abbott <labbott@redhat.com>, xen-devel@lists.xenproject.org,
 dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org,
 intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, dev@openvswitch.org, linux-kbuild@vger.kernel.org,
 linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com,
 Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
 William Kucharski <william.kucharski@oracle.com>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Edwin Zimmerman <edwin@211mainstreet.net>,
 Matthew Wilcox <willy@infradead.org>,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>
References: <20190123110349.35882-1-keescook@chromium.org>
From: Alexander Popov <alex.popov@linux.com>
Openpgp: preference=signencrypt
Autocrypt: addr=alex.popov@linux.com; prefer-encrypt=mutual; keydata=
 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
 jXz/74kjFsyRgZA+d6a1pGtOwITEBxtxxg==
Message-ID: <874b8c23-068b-f8e7-2168-12947c06e145@linux.com>
Date: Tue, 29 Jan 2019 03:12:24 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20190123110349.35882-1-keescook@chromium.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 23.01.2019 14:03, Kees Cook wrote:
> This adds a new plugin "stackinit" that attempts to perform unconditional
> initialization of all stack variables

Hello Kees! Hello everyone!

I was curious about the performance impact of the initialization of all stack
variables. So I did a very brief test with this plugin on top of 4.20.5.

hackbench on Intel Core i7-4770 showed ~0.7% slowdown.
hackbench on Kirin 620 (ARM Cortex-A53 Octa-core 1.2GHz) showed ~1.3% slowdown.

This test involves the kernel scheduler and allocator. I can't say whether they
use stack aggressively. Maybe performance tests of other subsystems (e.g.
network subsystem) can show different numbers. Did you try?

I've heard a hypothesis that the initialization of all stack variables would
pollute CPU caches, which is critical for some types of computations. Maybe some
micro-benchmarks can disprove/confirm that?

Thanks!
Best regards,
Alexander

