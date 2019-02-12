Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 060B8C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:46:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C02CE222C0
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:46:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C02CE222C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C4DF8E0002; Tue, 12 Feb 2019 16:46:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34AC48E0001; Tue, 12 Feb 2019 16:46:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EE278E0002; Tue, 12 Feb 2019 16:46:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D77BA8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:46:24 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id x134so154905pfd.18
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:46:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8oesOAtYPb/1XdKw3jTaik+ps+uMcm6JCogfmGVy/r4=;
        b=cE/M5Sl/eob6NVzbF0URLkNkT2MOFp8qb4LF87Eu2HCFuj1nyaGI/6bwsvIabKGxUT
         wHm4SCz4pCWS067iAgCedQEiKu0ShfCkdkae3MQnPSPZgNH4o5HUWjBuOpfuW6iBrdZ8
         KmYj0g0gFAkqjhqNT88yqJhaG4FMZXMcTZNKQRj1dVjb17GU24Cm7MtHUWy3NAoaZa47
         K1RcC30NSQRYExoeNut+llcIifAMXTBWdtO/YJaQSyw5Xwq8iI+5LlpsVny6UFFhhNa+
         MppF+IvO65aVKz2sFfe+IOALXZHOcSZF+ojZY3+TcVOFWmDNM4JCLlAZoCAbLcY4TUjG
         FJIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuZnVOkdzNsZCB5ebS7IBlHHTXO2B9Eyo40FdHb4U5HPiC1+IFA+
	DGLzTtp9hX0H+QetUf03KGsxwIiKo433Zg2Ao1M9E9cNmMOiVCS4H7n+9E6kBII6suxj9qc9O9O
	8VoQWv/KavYHX3ta2Elc3OJAh6eKD0OPvk/vJx4OgX5ydkq5kjogMUPt0M4RHAEz5bw==
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr5539359pgr.333.1550007984527;
        Tue, 12 Feb 2019 13:46:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibjs97CQca06AHoPTQQl8kAEEYJAIb0VNcZMXdXewvf86WnSmXB6+mKWAK6YoSLdMH6/Oxh
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr5539308pgr.333.1550007983814;
        Tue, 12 Feb 2019 13:46:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550007983; cv=none;
        d=google.com; s=arc-20160816;
        b=hBY/vnHKF6UbqmQldN1rFdDzUnL1c79HKvi/BvkdAXZkvg/2jAf9eLlcqv8blYRI6t
         sl2HGG1nLIkX6NaAq6nXtmPaidmMjf/c8QDdwGoyN71fqk0eF/Ikq3U4u9pNGCAiY6qS
         7ZbXdCv/66fmGGlVz3FvUeVn+wNL8r7Cv5MazL50c1+2324vDAi2DnVmp4dWTOJaSHxs
         jzXFvk4DGG7Qtil9rqw6IqsS/ZutS1/d+9qA7XGug665e1OCbr+AO1eYRX4iLh4T66HI
         hM033lhpp1ZQB6kqHAN8POaYpFXwxNDJ294Jm3ZenNov1MYizkCQQXNJ8EHD6esT6Db3
         IGnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=8oesOAtYPb/1XdKw3jTaik+ps+uMcm6JCogfmGVy/r4=;
        b=N8KoE0n9tz58uiVgmE3yPoucyNTrs78Br4q96jyrT7Z+8CiYNhRFXuqx4abiMjxYxp
         +33sltZy1u/xyUu2gVoMzhtpo23wWQj1CcRZ/xBXVZQtjQam5MVgLJm4MD6wSluEJ8oH
         CH5Zr5jssJM+3RmK95XLJRKWg2NEhDLa6kpMgvDri6xrMOj6gMWDV8r4+l/FcbV4EvvX
         5GG2dlXiwUT/KpEeX+SLErcoOnj/f6vVLtzgaKqREoUGGdfOlRIh1YAIkmgQYrsdKfYs
         63DAJ3A/vxZGMkxLtmE3DPynGxML+df9vik6DXk3c4D28IQD8NjXKozlLb+UXiAs0OjZ
         ZMqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n14si5230204plp.257.2019.02.12.13.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 13:46:23 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 4C530E67A;
	Tue, 12 Feb 2019 21:46:23 +0000 (UTC)
Date: Tue, 12 Feb 2019 13:46:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: keith.busch@intel.com, keescook@chromium.org,
 dave.hansen@linux.intel.com, dan.j.williams@intel.com, linux-mm@kvack.org
Subject: Re: + mm-shuffle-default-enable-all-shuffling.patch added to -mm
 tree
Message-Id: <20190212134622.9e685e9a955915d1a058ea99@linux-foundation.org>
In-Reply-To: <20190212085428.GP15609@dhcp22.suse.cz>
References: <20190206200254.bcdZQ%akpm@linux-foundation.org>
	<20190212085428.GP15609@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019 09:54:28 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 06-02-19 12:02:54, Andrew Morton wrote:
> > From: Dan Williams <dan.j.williams@intel.com>
> > Subject: mm/shuffle: default enable all shuffling
> > 
> > Per Andrew's request arrange for all memory allocation shuffling code to
> > be enabled by default.
> > 
> > The page_alloc.shuffle command line parameter can still be used to disable
> > shuffling at boot, but the kernel will default enable the shuffling if the
> > command line option is not specified.
> > 
> > Link: http://lkml.kernel.org/r/154943713572.3858443.11206307988382889377.stgit@dwillia2-desk3.amr.corp.intel.com
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > Cc: Kees Cook <keescook@chromium.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Dave Hansen <dave.hansen@linux.intel.com>
> > Cc: Keith Busch <keith.busch@intel.com>
> > 
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I hope this is mmotm only thing and even then, is this really
> something we want for linux-next? There are people doing testing and
> potentially performance testing on that tree. Do we want to invalidate
> all that work? I can see some argument about a testing coverage but do
> we really need it for the change like this? The randomization is quite
> simple to review and I assume Dan has given this good testing before
> submition.

Please see the mailing list discussion.  Without this patch the feature
is likely to end up in mainline with next to no testing other than Dan's.

If it disrupts people's performance testing then whoops, sorry, but we
wanted to know about that!

