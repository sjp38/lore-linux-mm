Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 943B2C43387
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 01:37:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EEB9218E2
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 01:37:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="EIUy28w0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EEB9218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F2238E0003; Thu, 20 Dec 2018 20:37:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A0C88E0001; Thu, 20 Dec 2018 20:37:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68FD18E0003; Thu, 20 Dec 2018 20:37:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3FE8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 20:37:40 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 41so3942321qto.17
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 17:37:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=HRl5j/Qx65fd3QJepQc0eeywK0XPZ4vo8oAxPUt+UBY=;
        b=ESEhL2dLC/UkW2blxxbuE7XDR+VoQKxQd/j8mlyxZCbCWYutPn194BvpTMknbl4K53
         clbx/B7SdFLv9aKo9/yzEfPh0M20QJulrnJ5QkbHBS9XMFv+/p3WlGpSIX7uhyfBIdPx
         cyqWoUMfK7cr9jS6WGytf/SUrq4dj4aIsmVD8toZAmd0Wl97fNC890nCGBg4wJU677VS
         muAC6FpAanRt4xrehGf7HVyheic64NO21ZOdQOXJ0Z1Vi2bZwdfxNC7r09bGK/BkzsAy
         BhQcotlnKHyZTrmbi2NekcXh0ltgcvbPfo271PHC5YL21iPMuf+2fCCBt7tENhSF7Eyy
         q3cA==
X-Gm-Message-State: AA+aEWYTV+GWq8WUsSJyCuSgegS7unumF3u8KjQNep1pzisXq7++k8be
	ltxSXpemkPEaxIqjFirl5JyGmHCHdsovaQ1/uiDtFZEKPddG7RtTGD4VhkBGAWQ2ka01UzJGR5O
	MoK2oWHyZxfe7o0rBCedh9sAfB1D0C9fHSIXnDgK3azlrJVTKLglBmeCh3DkpUHc=
X-Received: by 2002:ac8:4258:: with SMTP id r24mr518081qtm.213.1545356259887;
        Thu, 20 Dec 2018 17:37:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN74v3cpuaQHO7d6M4nfo1s85p6HqbXfbV6GKZRQJBLM8ZXsqf+R6/h/Q0Bk7i+UO6mr2VzZ
X-Received: by 2002:ac8:4258:: with SMTP id r24mr518052qtm.213.1545356259211;
        Thu, 20 Dec 2018 17:37:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545356259; cv=none;
        d=google.com; s=arc-20160816;
        b=mXoRqUT0bZK7DXEhmddZO5sZexnFkWTzOUG5qnshfELV/ISI5T1ixuhTEc5zkeaDS8
         KvQUFW/WQrjzsZYJdrAuHPrtFPA9pkaAxGP4bXeblbVuXkg7qJmUQTE7AN5GupQBILbN
         +1/haZ7x6Jg1AClCWx8wrWtticfrO6lEKyImoebCl0zhZSkpftWwONBpuXx1zWWDXkRV
         xF8h4UuVFbi2qGTW2l4z4McE0zvVU/BcuJDRgkY3aiiChX3RklSSvIBVsN78FnPVkBm0
         OZdP/cUH5Bu2aEEMX2xpxbPaf4G+qLZ1MI7bsn6EG0VYF0tEvgSh/PvvKrHpD8Wh098L
         j9Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=HRl5j/Qx65fd3QJepQc0eeywK0XPZ4vo8oAxPUt+UBY=;
        b=AyTStUM7qZ6anNWPKeqZ9cZhXpkbKCe2RGHtZv8g6Hsgeu7qEw01NS1S5J5AsmuC+u
         uSDgh3dKg1OSOnwtjap6fF34xcPkZk+i4xk4FtjaL/uiy4p4uSx5PShLiwuJt7KKZcdC
         TQwRP22ICEzabdmw6mXxixMRmU5X8wxvhzmTLEjCHSER+dadOhfFsJyjNwK1vpwOxG9+
         FVM+4l0b6BXgY06ePFGuhIiTA0wosiL4aMpnT9jFbvqJTOL6Q7E35noyoD72l7F2mRQk
         PvbyumwU2aRqiKMREPv10dPY11FvSE7HUmFYkG6yM18RTrXpn8WROzM/s9PFH6/YD06h
         /IRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=EIUy28w0;
       spf=pass (google.com: domain of 01000167ce692d0d-ef68fdc8-4c30-40a4-8ca5-afbc3773c075-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000167ce692d0d-ef68fdc8-4c30-40a4-8ca5-afbc3773c075-000000@amazonses.com
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id f10si2166720qvm.149.2018.12.20.17.37.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 17:37:39 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000167ce692d0d-ef68fdc8-4c30-40a4-8ca5-afbc3773c075-000000@amazonses.com designates 54.240.9.46 as permitted sender) client-ip=54.240.9.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=EIUy28w0;
       spf=pass (google.com: domain of 01000167ce692d0d-ef68fdc8-4c30-40a4-8ca5-afbc3773c075-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000167ce692d0d-ef68fdc8-4c30-40a4-8ca5-afbc3773c075-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1545356258;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=QvZfLWaTQxDT1rO5haOeoHv4lCWD39UeIZR4Rk2b6kg=;
	b=EIUy28w0eFpM4fThUKcrBdkumWLAJY1RsMGHoOlvaPd4/LgCXEuJpEyuQroIi8Dn
	gsJuOZxWDYnIZoqjvSGNMwjZNI5xiNRpSQmhXQfqTgg2BaVl4lXQqQhieSp/NVctxNj
	cRr8ucKLqStav7XUjRWKfaSE80lEC+EPcCQ1BJWQ=
Date: Fri, 21 Dec 2018 01:37:38 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Andrew Morton <akpm@linux-foundation.org>
cc: Wei Yang <richard.weiyang@gmail.com>, penberg@kernel.org, 
    mhocko@kernel.org, linux-mm@kvack.org, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/slub: improve performance by skipping checked node
 in get_any_partial()
In-Reply-To: <20181220144107.9376344c2be687615ea9aa69@linux-foundation.org>
Message-ID:
 <01000167ce692d0d-ef68fdc8-4c30-40a4-8ca5-afbc3773c075-000000@email.amazonses.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com> <20181120033119.30013-1-richard.weiyang@gmail.com> <20181220144107.9376344c2be687615ea9aa69@linux-foundation.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-SES-Outgoing: 2018.12.21-54.240.9.46
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181221013738.MG2hpvQmmXOx-E6A7LTdZloN-tz6-1I8cRHpE-N2l1k@z>

On Thu, 20 Dec 2018, Andrew Morton wrote:

>   The result of (get_partial_count / get_partial_try_count):
>
>    +----------+----------------+------------+-------------+
>    |          |       Base     |    Patched |  Improvement|
>    +----------+----------------+------------+-------------+
>    |One Node  |       1:3      |    1:0     |      - 100% |

If you have one node then you already searched all your slabs. So we could
completely skip the get_any_partial() functionality in the non NUMA case
(if nr_node_ids == 1)


>    +----------+----------------+------------+-------------+
>    |Four Nodes|       1:5.8    |    1:2.5   |      -  56% |
>    +----------+----------------+------------+-------------+

Hmm.... Ok but that is the extreme slowpath.

>    Each version/system configuration combination has four round kernel
>    build tests. Take the average result of real to compare.
>
>    +----------+----------------+------------+-------------+
>    |          |       Base     |   Patched  |  Improvement|
>    +----------+----------------+------------+-------------+
>    |One Node  |      4m41s     |   4m32s    |     - 4.47% |
>    +----------+----------------+------------+-------------+
>    |Four Nodes|      4m45s     |   4m39s    |     - 2.92% |
>    +----------+----------------+------------+-------------+

3% on the four node case? That means that the slowpath is taken
frequently. Wonder why?

Can we also see the variability? Since this is a NUMA system there is
bound to be some indeterminism in those numbers.

