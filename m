Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EFEBC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 11:37:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 047CC2083B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 11:37:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 047CC2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A491D8E0016; Tue, 12 Feb 2019 06:37:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F66D8E0014; Tue, 12 Feb 2019 06:37:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BD5B8E0016; Tue, 12 Feb 2019 06:37:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6F58E0014
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:37:18 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id t13so2342853otk.4
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:37:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yT4IPO/lRNRMAXTuft6ex8gE42ArWDNBcEN+eM8n/ik=;
        b=a/RBhmvkVbMnVDseACpN10plGclKNQ0h/8F1M94aGAzb3VjlorX3m2U6jUj+fjM48p
         n7CsMEhe4VHXcqoXfKvXUKjcI51M62hB5kB1a+2FOgTwNH2uVp8GvREljDr1T4mtyfND
         XAljY4OtsVsK/1ysyKpY3iBGMjR+T/6pvG/ph6jM54jbK893Z2tbxkzx+k8x+oPF8IvW
         GGfwJtOM2aejJGxGEJhiZEtOcK3CdTsYOAYIAkYvkQrxMuRJc7UbwC5v+x2ulIU9zaO7
         rfWnfE7qmqzcZORGtSDBmDR/i3F0R/KEM5A5kJmkRplAz3FSPkovkWsUWsQeqr+Fx29h
         yXqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuY8I6to72QatnDKd3Kjjz6pk1cJWEkRAGKPzj1MpOf6qYor1xYi
	9JoAaOnmyPvWzoDa/y0vfpa0irFkk6m3hEWp3iPoo214NiO5kMHYIsjoEYH2iFQv+KyIOQbpvGd
	ORhkz1u6uhnE+unNOLFREZakGGTdHIa6phnSadumo3tP4y+2GbZW9C1/hTVMVrJfvDQ==
X-Received: by 2002:a9d:19e8:: with SMTP id k95mr3059558otk.209.1549971437991;
        Tue, 12 Feb 2019 03:37:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZj2uQ21h6OOL6OIEkxbdsLKbt6jd/XVfrxq54uZm3Hbkv4OElb4iIbkM/4ZW0xTMglZRh+
X-Received: by 2002:a9d:19e8:: with SMTP id k95mr3059519otk.209.1549971437305;
        Tue, 12 Feb 2019 03:37:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549971437; cv=none;
        d=google.com; s=arc-20160816;
        b=hQvaouVmmSQNj1WwKV9MJtGp/z1LxHPO/zCK0SowmlkQkpGkcvzPfl5FMG9yLeyq+P
         Yx/pUzleyHTzXLkHmbzESkZkDTJTUrQwWf4NdKucOnf1v///U5PpdZgVYO8JrwcRmwdm
         iR4oaV2gpotXFMEIr1Pni7tARR6Ytc0rLCiHyuLIhBnjZQUC81obETxa1ZfkWUG8B5um
         T/nN0noCKEjGnyiJccq6t9WCPoOS9JObL9b7JrqHc+TKMjJz9gEah5YT2vAdqOSJElRi
         sQqTXoKuXoPKsDsfwpldFWNQNjTqS+M/sjUGc6OTkX8hmVv4UIQEFeVsACRoNkqYY4/2
         2vBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=yT4IPO/lRNRMAXTuft6ex8gE42ArWDNBcEN+eM8n/ik=;
        b=DIyGTC0M4It6F4dRLcnEnIJtH3qUSdNwBuwvruDqvbrwoI/PVdZsEpsoOO5Gg5zGjT
         BkPa4/+HIWG9pwxIIUOEI3/6fdYHeU6PLiEktETVYPVltDSr1UR0swM0l1oAc9+t3WRC
         xB6NvNGCE1dR3Qon4DDd2KLig6pV7ghs//gkL4CD8miE8MGorvxEyVB3eWCbcxtfkPEj
         oWWg2pBIkunSLrMk//NGADDf1kWa7JZcWM4+re4IV4m6OTafIFZk+xPD/1iPoWcTlFt0
         u5tw6NcR/vTvXw8/cJP0yPsFy3z4jpu4DC+a+TAZ2M1sUwdwchiqoxuA+1eVpBGyJRvg
         BTYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m5si5732336otk.80.2019.02.12.03.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 03:37:17 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav101.sakura.ne.jp (fsav101.sakura.ne.jp [27.133.134.228])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1CBbAis075795;
	Tue, 12 Feb 2019 20:37:10 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav101.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav101.sakura.ne.jp);
 Tue, 12 Feb 2019 20:37:10 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav101.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1CBb9KN075784
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 12 Feb 2019 20:37:10 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>,
        Chris Metcalf <chris.d.metcalf@gmail.com>,
        Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org,
        Guenter Roeck <linux@roeck-us.net>
References: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190212101109.GB7584@dhcp22.suse.cz>
 <82168e14-8a89-e6ac-1756-e473e9c21616@i-love.sakura.ne.jp>
 <20190212112117.GT15609@dhcp22.suse.cz>
 <20190212112954.GV15609@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <7495a10a-08f5-6b0a-7d39-1665ba0c9325@i-love.sakura.ne.jp>
Date: Tue, 12 Feb 2019 20:37:11 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190212112954.GV15609@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew, please replace

  mm-swapc-workaround-for_each_cpu-bug-on-up-kernel.patch

with Michal's patch.

(I didn't debug this. Guenter already debugged this before reporting.)

On 2019/02/12 20:29, Michal Hocko wrote:
>>From db104f132bd6e1c02ecbe65e62c12caa7e4e2e2a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 12 Feb 2019 12:25:28 +0100
> Subject: [PATCH] mm: handle lru_add_drain_all for UP properly
> 
> Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a ("cpumask:
> introduce new API, without changing anything") did not evaluate the mask
> argument if NR_CPUS == 1 due to CONFIG_SMP=n, lru_add_drain_all() is
> hitting WARN_ON() at __flush_work() added by commit 4d43d395fed12463
> ("workqueue: Try to catch flush_work() without INIT_WORK().")
> by unconditionally calling flush_work() [1].
> 
> Workaround this issue by using CONFIG_SMP=n specific lru_add_drain_all
> implementation. There is no real need to defer the implementation to the
> workqueue as the draining is going to happen on the local cpu. So alias
> lru_add_drain_all to lru_add_drain which does all the necessary work.
> 
> [1] https://lkml.kernel.org/r/18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Debugged-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/swap.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 4929bc1be60e..88a6021fce11 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -660,6 +660,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
>  
>  static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
>  
> +#ifdef CONFIG_SMP
>  /*
>   * Doesn't need any cpu hotplug locking because we do rely on per-cpu
>   * kworkers being shut down before our page_alloc_cpu_dead callback is
> @@ -702,6 +703,10 @@ void lru_add_drain_all(void)
>  
>  	mutex_unlock(&lock);
>  }
> +#else
> +#define lru_add_drain_all() lru_add_drain()
> +
> +#endif
>  
>  /**
>   * release_pages - batched put_page()
> 

