Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62FB9C3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:43:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2256F23400
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:43:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lCya9oPW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2256F23400
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA9636B0003; Wed,  4 Sep 2019 03:43:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B31506B0006; Wed,  4 Sep 2019 03:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F8A46B0007; Wed,  4 Sep 2019 03:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0223.hostedemail.com [216.40.44.223])
	by kanga.kvack.org (Postfix) with ESMTP id 7747E6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 03:43:18 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0D09C180AD819
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:43:18 +0000 (UTC)
X-FDA: 75896447676.21.wing98_912c9fbc2b13a
X-HE-Tag: wing98_912c9fbc2b13a
X-Filterd-Recvd-Size: 4166
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:43:17 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id gn20so9190097plb.2
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 00:43:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Qj+DAxsSIX3ZqKCcNj9WFrsINQyctNKm0DapU8GePMg=;
        b=lCya9oPWLL6Z2sCvMqFx61guCAYb06hPqKEzeto7EkIbJJkzeWfSzu7uAmnoTtP8ml
         xwSSllg+7Cg/uFNKX3vW16GYIPDhCkAmstIR4IRc7GPm9D3jCJl1sgbuWkmzesSTQa1k
         VJyOgK5+Mv7W53iq0EhizOvaAZvrpzkaEotfxKWSziTRO3SQwvKiakik9sZQSga92v12
         CF8lOSfMAKCJw8Qxi7kpK3/tCDkU3CULfpbAp+Lj3IGZp+WZtzlPfFHzYLA1zDI9nhXY
         hxsUV472mag4UDl6Vv5Go5942fXu/+UV8xMWd9JR43SMVyF30BYgkHYkcg/JrLxHLCR7
         mUeg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=Qj+DAxsSIX3ZqKCcNj9WFrsINQyctNKm0DapU8GePMg=;
        b=s79Rc7WGLU8sWIld2ndOGWIfTbTQ2q8Tx/WGqi5nGmikhJzK1BqOwwa56UZ+G2o0HO
         vq6Z59c6BQPJXks2h6+otvRBwAEH/QyFZyIhqSg7uB2dNUkcv6WPrZTfXnxTQoj+vwQh
         fzKIeMnxZEBhGLE8Q85DZxBImIzsaMoDjsrlWcu3+gFeh2sBm2cWbir/1HrtqdTl43pP
         2VYziRHI6zP3DSFj0oXAv22ChALBEZxnMaCY1uciH2do2yYbZJf47AZPMuWVLtMt6Vom
         WGZwh9zESSZaS01OSz7vcILCtR3uZVMbzGyVIn0Wrh3FhklRzapDXxHLOKlfILg+sVpY
         vFsA==
X-Gm-Message-State: APjAAAUXHAeI9I28VoGwZhOIrWTVTjLwFYKhOmOlZDHxiKE/1YfahN9f
	OsAhkCuAvMuv2bTRpBGd8h0=
X-Google-Smtp-Source: APXvYqwf8YuF18rL+t+nFsRll+w6Tgkdib8E7Z6IJLldxGfK/Upkt0ST6okY6POe2h+lSN5PdkHtzw==
X-Received: by 2002:a17:902:6b88:: with SMTP id p8mr38148119plk.95.1567582996648;
        Wed, 04 Sep 2019 00:43:16 -0700 (PDT)
Received: from localhost ([175.223.23.37])
        by smtp.gmail.com with ESMTPSA id c6sm14214884pgd.66.2019.09.04.00.43.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 00:43:15 -0700 (PDT)
Date: Wed, 4 Sep 2019 16:43:12 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, Eric Dumazet <eric.dumazet@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190904074312.GA25744@jagdpanzerIV>
References: <1567178728.5576.32.camel@lca.pw>
 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
 <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw>
 <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw>
 <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV>
 <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904071911.GB11968@jagdpanzerIV>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000018, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/04/19 16:19), Sergey Senozhatsky wrote:
> Hmm. I need to look at this more... wake_up_klogd() queues work only once
> on particular CPU: irq_work_queue(this_cpu_ptr(&wake_up_klogd_work));
> 
> bool irq_work_queue()
> {
> 	/* Only queue if not already pending */
> 	if (!irq_work_claim(work))
> 		return false;
> 
> 	 __irq_work_queue_local(work);
> }

Plus one more check - waitqueue_active(&log_wait). printk() adds
pending irq_work only if there is a user-space process sleeping on
log_wait and irq_work is not already scheduled. If the syslog is
active or there is noone to wakeup then we don't queue irq_work.

	-ss

