Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5B71C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 20:56:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 995CD222C0
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 20:56:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 995CD222C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 398C28E0002; Tue, 12 Feb 2019 15:56:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 348838E0001; Tue, 12 Feb 2019 15:56:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25FFC8E0002; Tue, 12 Feb 2019 15:56:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9F2D8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 15:56:37 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g9so74717pfe.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:56:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZjhHrABKWpvvXOXLhMDMvnjzdr6hAbzpIaoKD+qqA/I=;
        b=QYcNgqU8gZ0dnWWck0902wXWHH0MSy/FXl7UWX6LvyA5jw15Y9G3Gm6cRv1wj9fndg
         +Y9+9/MirbItiPp0M+Pa9NpO2i02NGTgZKmpa0YlkJlitIHjGlD9zqM6U13oWFYjxvkn
         bKTfa3ZxWl8Fi7bT2NE/StFelZTotZ08Ppqoi91Bhb3+GIrwnHQ8zAAkNTaRscaJFnW9
         H4DgPHXI0Ef7lDeyPreS0DrrDPuYdzT9w2SmjBEwEy5rzSvMDsMN+ns7zVAE26Dcc7ga
         V4kxihHNJbPdzeem3rVAf7qGNnz+VhCYkUXWhr358m8u/tobkS9y/wkmrgPMGe10CeTk
         LX9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuaQIBP0faXBFZST15UrERktUs3VGw9/Ujqp7Frv8jSmqXmywnFA
	kUQk+dhPMsr7gbtAbqCFQpoWUk6epbTroArU9tqlAzn86hBNFtxp6JRbJl2CMz9ChdyZQkzy9HY
	yQ368XYddUH0kphqD7yetqp4HHeUF21ZhoZOgdtrKki1GahPr8pNOYp6HnaA29jWeiA==
X-Received: by 2002:a17:902:b615:: with SMTP id b21mr5936615pls.338.1550004997579;
        Tue, 12 Feb 2019 12:56:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia73D4xg2wiTqgYmR1d0temn9k4UCu8yI5782/PQXLwefXAAyBuhGlnv6mO93+9c1Z+KfOt
X-Received: by 2002:a17:902:b615:: with SMTP id b21mr5936571pls.338.1550004996811;
        Tue, 12 Feb 2019 12:56:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550004996; cv=none;
        d=google.com; s=arc-20160816;
        b=kgQCI1qDd6G+fzwZZ0ptHcThf4xpHljZXrtI6MPzmyZP2izWBAHmg/+7CbExXR46oM
         VwCIv++mY7mw7E30CQE6nFxiD0GEDAAdghukDq/hjtMQbmeRJ9rwcTf+SILl42ISTbbB
         P7YrMmychO825M3ceSFr6kmlTshIv6UHpxCh/C6vkH4B8fdrBSX5obqg8BY4+h9ed0Kj
         nkerq+pyEvvlXWCclWmBevSTTBkQLiD09z5iLxthJ7Ff36lnm07qzY9ua31CnGm69N9q
         vygYm9GS71bgHmD4uWEbH59q/EqbwIVrf/TWA2JriC951lvGUMvnVdnoGTsS3cyI3ww5
         1vSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=ZjhHrABKWpvvXOXLhMDMvnjzdr6hAbzpIaoKD+qqA/I=;
        b=p8dJb91CPCtvLK8dR0l9ND1PMonseAS1xJby1/RgFzvIiWS+g10vGHjuzwW4gd9n/R
         87cJCxJgVPpQly8qqyN1P5HByY0KKm1V3wfzQtiYhmWXyvJFQRK1qDD342g7ptBJ+ryv
         PyXyXJeD3h3BzQrBa71tHm8YyJ+sbYMVbrUtjGy7j0RGba6V2mkEZy0wkT6A4zbKKa3O
         4szlb8HUbr9gkXw7AmdKKydxYDk9eAQe/LW9AsxzwhwTbOEuve1pFm+xZ50uulQMRzWS
         MSKRGACO104MlhXtknEm8IV/H/r63zLb+HPOyUPkfETWxuM304At5hH7Y1HETRzVqbjD
         wX8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q77si5786278pfi.220.2019.02.12.12.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 12:56:36 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 2EB90E5C0;
	Tue, 12 Feb 2019 20:56:36 +0000 (UTC)
Date: Tue, 12 Feb 2019 12:56:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes
 <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds
 <torvalds@linux-foundation.org>, Yong-Taek Lee <ytk.lee@samsung.com>,
 <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko
 <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] proc, oom: do not report alien mms when setting
 oom_score_adj
Message-Id: <20190212125635.27742b5741e92a0d47690c53@linux-foundation.org>
In-Reply-To: <20190212102129.26288-1-mhocko@kernel.org>
References: <20190212102129.26288-1-mhocko@kernel.org>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019 11:21:29 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> Tetsuo has reported that creating a thousands of processes sharing MM
> without SIGHAND (aka alien threads) and setting
> /proc/<pid>/oom_score_adj will swamp the kernel log and takes ages [1]
> to finish. This is especially worrisome that all that printing is done
> under RCU lock and this can potentially trigger RCU stall or softlockup
> detector.
> 
> The primary reason for the printk was to catch potential users who might
> depend on the behavior prior to 44a70adec910 ("mm, oom_adj: make sure
> processes sharing mm have same view of oom_score_adj") but after more
> than 2 years without a single report I guess it is safe to simply remove
> the printk altogether.
> 
> The next step should be moving oom_score_adj over to the mm struct and
> remove all the tasks crawling as suggested by [2]
> 
> [1] http://lkml.kernel.org/r/97fce864-6f75-bca5-14bc-12c9f890e740@i-love.sakura.ne.jp
> [2] http://lkml.kernel.org/r/20190117155159.GA4087@dhcp22.suse.cz

I think I'll put a cc:stable on this.  Deleting a might-trigger debug
printk is safe and welcome.

