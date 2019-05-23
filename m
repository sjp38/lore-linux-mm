Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C9B9C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:08:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4435C20879
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:08:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lxTUeHWl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4435C20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3D216B0003; Thu, 23 May 2019 08:08:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC5F06B0006; Thu, 23 May 2019 08:08:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8D8D6B0007; Thu, 23 May 2019 08:08:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5096E6B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 08:08:00 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id p7so196863lfc.5
        for <linux-mm@kvack.org>; Thu, 23 May 2019 05:08:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tD+qhuLt5qsLm3SGbeSuel1UeuQsI4bGOp7Ijyc6Z9U=;
        b=GYGDC8B7fq+4LWJO7R2eDdLKgXPorMDIWLkVHEBBRqe/lC/0g/L0XgT+5dJ+MNROeN
         VHh8pXd0Z72wEjVYu4BW3kKAahYy1+WCzBaw8Ml/pS4PQ2XShLe3pq2D5+KDLFEmj9/A
         jo39fN9bkdaeKLZq/RReAIp1mHO89HJ0F6we4wgTNqcJ5VBLwRvqFYTAQJjC1PEp8d94
         9Gbqke8fpKQlSZa4XnFJUAv0HEqCnyKXwIDPuFvIPxiTm7Ja66yDfDYzyeG3OdcGUZAW
         RJtoidFRf9F6ToB6LSF28mxio9Jc/ShLupUihcD0EG1+x71GhLBJRvKN+vaMecUTolIT
         av2g==
X-Gm-Message-State: APjAAAVIItkGSPIbB03V5/MUljq7heTjWd3M5MCrrgWx4XDK2B0wf/8K
	kLvvX95QJo2OnMZ8s93oRD0HeiCDQhG8F45P6vJ4D6gWXMtW1n79D57YH3XXvM1sQqHc5cNJAoT
	GbyEkVSCbx0W454k1AOANKpWCxLwDJAKguPAu/O9ar7q3+PpDUOHIpgCRb1SMlsXY4A==
X-Received: by 2002:a2e:885a:: with SMTP id z26mr4160688ljj.35.1558613279761;
        Thu, 23 May 2019 05:07:59 -0700 (PDT)
X-Received: by 2002:a2e:885a:: with SMTP id z26mr4160639ljj.35.1558613278966;
        Thu, 23 May 2019 05:07:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558613278; cv=none;
        d=google.com; s=arc-20160816;
        b=BCw+TCIiYvNCoZ9kUUchWZ13Waui8zNUWbLlp3n8i7RIanSO+48W1a3VX5F5hCAEUs
         EPr7u2UL9VZceVWEWgP/9eId5o7GPNULgOrSDn311Z5Xlq+dDaoP2J2D4fD31HlOHUY0
         TMlPnCtgOxKqLYGbBotbYpfjynnzyyeFN9SZsdLzZYpmr7mKm94+8cJw2EQG+BYeinSS
         MGsWx5Pileg8ghn2D5V2/t8oNAuEGeRDTA4TiieCBk7FLS9uJ3YFKATFnIbevhxVtwVC
         Pzfb+k/DhN3wabndHurPRLKzfIX/co/+Vo3twfl51krz+ZH53Ahw9KFCtvjtFuWzbAMf
         xUhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=tD+qhuLt5qsLm3SGbeSuel1UeuQsI4bGOp7Ijyc6Z9U=;
        b=G2Ruy3o5Bu8aJHjw/KCrCMoQPPqJbcXqprdBE1vAsn8xDUq2HXQKgDHtQTDvZZrhvP
         1XhZF/Slr0nRrk3EAx5plVK9kl3SX/GUII4lbt4VDS0/vDM2OwPE2uY1q9npJXwR+0AQ
         o0L5xEc6KnwZ/Jbsh7QagfUyXQRRDsBqar4mQD+WxLYZhWy8ZexIzw1hdi6bIWS1908w
         W1aZg3RgYB86SnY108hhWEEC0qpgRH1WxEekRxduog4/bfqmN80994BvP+T3dlUB5CFB
         kUjXX4GUKv2GGz38DgmIGWBAdM0toX2EYx9lq/hcWE9LT6DsmQBHqiDiY1Kge8GHg6Dw
         HbzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lxTUeHWl;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6sor2466432ljg.27.2019.05.23.05.07.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 05:07:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lxTUeHWl;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=tD+qhuLt5qsLm3SGbeSuel1UeuQsI4bGOp7Ijyc6Z9U=;
        b=lxTUeHWlC9pmRKtqbsZO74um4vrYUDvyMnqMP/IRnFvJuuks0xkcEzrhtDl4a59kIM
         Bri1WS9kqQHVRSMnIMXzO71FtsYHWnd84w5lLdXsWEes/0zLIB5q9gaYkQHXmPlk2plU
         OKGX3MloEsBqDa8iAv6NrgdmlI/uGyq5V/NAeeOT9gd8+/lFxGXsrMudMPU4mWB4p0TP
         tDQnVjE0Zea7yIQJQyVYztjQ1dOMItqsXifbf/nhC8AhgfiDjdzmRsaOjAGXL8VOQqyQ
         gOm3MRbJh8e1NZnKGJfuXNebA0h7/o94/y6uPZKLjsvFmi+ZU3EigKiK+DLGqsrZd4Ec
         WN+w==
X-Google-Smtp-Source: APXvYqwqnEnLn8hPK/xqWSwuvz6thK/QrMFBvfuKWJmH5rjvl/IzgIoyR0RZeSN9VPN81s8NfOTYHQ==
X-Received: by 2002:a2e:864e:: with SMTP id i14mr17271725ljj.141.1558613278568;
        Thu, 23 May 2019 05:07:58 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id z11sm5868082ljb.68.2019.05.23.05.07.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 05:07:57 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Thu, 23 May 2019 14:07:54 +0200
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Message-ID: <20190523120754.4e2wak7mn7t3wfkz@pc636>
References: <20190522150939.24605-1-urezki@gmail.com>
 <20190522150939.24605-4-urezki@gmail.com>
 <20190522111916.b99a18d67bc76f7cf207d9e6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522111916.b99a18d67bc76f7cf207d9e6@linux-foundation.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 11:19:16AM -0700, Andrew Morton wrote:
> On Wed, 22 May 2019 17:09:39 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:
> 
> > Move the BUG_ON()/RB_EMPTY_NODE() check under unlink_va()
> > function, it means if an empty node gets freed it is a BUG
> > thus is considered as faulty behaviour.
> 
> So... this is an expansion of the assertion's coverage?
>
I would say it is rather moving BUG() and RB_EMPTY_NODE() check
under unlink_va(). We used to have BUG_ON() and it is still there
but now inlined. So it is not about assertion's coverage.

--
Vlad Rezki

