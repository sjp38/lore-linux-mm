Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E45AC4321A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 21:12:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0223C20859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 21:12:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="XazJMO6j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0223C20859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 793466B026B; Mon, 10 Jun 2019 17:12:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 743526B026C; Mon, 10 Jun 2019 17:12:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6599E6B026D; Mon, 10 Jun 2019 17:12:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBE46B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 17:12:44 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g11so6397557plt.23
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 14:12:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x6ELUSb66g+Sv6aDEf/lkOuMqLiIrBzpc03LqBhDjWU=;
        b=casUvnHgFzF+9YT8MHnXsAp6rdfINq5KdTcVSTfdiDnPemqp5fIbbNvd1LUHJWeoOn
         Tr5Se2KypIFzXB9z/xw7jaD2fimQwY+HsFOqf3nugUS77sASiMsEi8e67RPmSsjGRgyg
         ewCOjsYsdunz+1g1rJjUAQYdmNhjLwoPnsCrIXRyPJAMn3M1hdlvSYa+1tznOakNniP/
         xMuyVY5GELHQQLeijURnVSy612jExW09SEE3PjhZrhHUjLzBOKgOJV5MkRiYiOMxikMc
         FmNjMYBlw7NUzB7GXWFHj8+o/YNwbTLqJrtyehvW5kETV42h6fhW93XlBb5BKx6nxUKc
         hrPQ==
X-Gm-Message-State: APjAAAWyPFFM91deWAKcbmMAA47EoL59Ng26T5oSqFA72eH91WSMCiQJ
	dp1aEBAB1r1wUGGt0hf9i1wyoTIRExY7mxEuUSybVx5jzrL84mxuO6dQrCXTwU281oeXyhm3G4F
	IqUxbkZPbKBgCKQCTg3CmY4+MBrFC16LAxb6/A15Hp7k0qQq4ERFJkIwCV31wCgMduA==
X-Received: by 2002:aa7:86c6:: with SMTP id h6mr39556231pfo.51.1560201163885;
        Mon, 10 Jun 2019 14:12:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNxQiKcRxUh5AQOK6yBBi+OtKhFJMvPiOD2nw3A9T3giaS2eFqR/gi+aQyS91jswfbjpM+
X-Received: by 2002:aa7:86c6:: with SMTP id h6mr39556175pfo.51.1560201163282;
        Mon, 10 Jun 2019 14:12:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560201163; cv=none;
        d=google.com; s=arc-20160816;
        b=DIX29chXeVCSva7mIBibpbyEe6w3aUn4gP8rVE8OlX8jxyB6cX8wM04vK/yMkDx4H4
         dumXGxE3VtTXtuypXMGGTvtob3Sjx0ngR8/TCoTakr0K37dCf9xKeCjW2Qz5H+GRHu2v
         JNVOiqDjo77P7QLJqukmwJyg3GDbV91tEF3W/y7RBYyT59k0p6XHY1pjAXtFsGg0vIJO
         plBwkeKccF91be6HtBwHG68YN9Xq+lUv2Fw/tJvp+XDEs5GB+eIgK03Qt/AyRmZ2AtxK
         Ag+773EPRGcziJIZCCzcmcnMLDgK5TrbKff6Mh/D1HKycdvOnVpvfFOUk2QDVRKXFl4i
         IZFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=x6ELUSb66g+Sv6aDEf/lkOuMqLiIrBzpc03LqBhDjWU=;
        b=ye9AmHIacSMnPz7N/+dOlwQfhNIxqk/yAJ647OClPsYeZ7Swf5ddCZDnYGHJZ+v4Tb
         1V4Y0DDT1ryGmfRmKVE/kAswTOzkmm9PLo/t14cFGw1R35lxpwAF4tLN4UHXp7hqgLjp
         KOuEnGrtXiJXCs5Y1fnLZF88noeo9fkaSLtk9O6VmZcC90e+8ZbMblU2DSXq1jB/whhz
         zs58ps3WnlK5DF01OhHA+yzUMUZf6AGHHZPehnTabGOF9lSZEA/1oapNPyvf3SV3RuKd
         ZqyKwAWsKIWfcVBjX3nU8s4lbfje0yFU7mPbIPpeDgw6yP6NU6rVVDVbF+pRl8PH+ssl
         Ey+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XazJMO6j;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q7si5485764pgc.374.2019.06.10.14.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 14:12:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XazJMO6j;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9B71420820;
	Mon, 10 Jun 2019 21:12:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560201162;
	bh=8je0MK0bocj0zWXxaQQ6LU+krcOnSQ9zSaPPfpPpEYg=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=XazJMO6jR8eoi6VccMlv7fWq+F3FBbJZPEUenFi4B6Jlcrc+mcpHRnNDq+7rjQfT8
	 n7unTD39ELaPEE4VlUc8QsE4mwTpPIl+yv7TNX9FpfZ5OSUiyRuct/3V2pZIgI0xeS
	 /2jflj4AMaN0jytT7I+iZfu1vLePx0siLdTdafL0=
Date: Mon, 10 Jun 2019 14:12:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: mhocko@suse.com, anton.vorontsov@linaro.org, linux-mm@kvack.org,
 shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/vmscan: call vmpressure_prio() in kswapd reclaim
 path
Message-Id: <20190610141242.382cfefa2c98b618d12057fb@linux-foundation.org>
In-Reply-To: <1560156147-12314-1-git-send-email-laoar.shao@gmail.com>
References: <1560156147-12314-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Jun 2019 16:42:27 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:

> Once the reclaim scanning depth goes too deep, it always mean we are
> under memory pressure now.
> This behavior should be captured by vmpressure_prio(), which should run
> every time when the vmscan's reclaiming priority (scanning depth)
> changes.
> It's possible the scanning depth goes deep in kswapd reclaim path,
> so vmpressure_prio() should be called in this path.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

What effect does this change have upon userspace?

Presumably you observed some behaviour(?) and that behaviour was
undesirable(?) and the patch changed that behaviour to something
else(?) and this new behaviour is better for some reason(?).

