Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65E7FC3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 15:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CF8E21726
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 15:25:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="j+V6+/Z8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CF8E21726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2D8F6B0008; Fri, 30 Aug 2019 11:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDDA66B000A; Fri, 30 Aug 2019 11:25:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF39B6B000C; Fri, 30 Aug 2019 11:25:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDC86B0008
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 11:25:32 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 27F501F86B
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 15:25:32 +0000 (UTC)
X-FDA: 75879468504.25.juice74_6a7dbc5a9e642
X-HE-Tag: juice74_6a7dbc5a9e642
X-Filterd-Recvd-Size: 4500
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 15:25:31 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id g17so6449009qkk.8
        for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:25:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=uAGNj/k9sxhyWPF4gW8v9ANxItk70JmBhK3Bz890W+M=;
        b=j+V6+/Z819VI1YZCoOnBj/oMDBF8SifHtR2Py7Q6rcAn92pGtORGovoGCON3Xa0lEX
         mxAwlsSE96mMR4c61G9G8QRLocu2g29Ge8DsiPpZhLQtBn5g7rnvG1bZS0vRFyLLpUTi
         KFDkNrI8kkq2QeMA60xq6RRi5XmiTP6vF7tokvFja6/cKXod0up2/W3LB6o9eFp4H/yY
         LJ6JRhF31aQpNRTjiSXK9uHJasLwOO4iLkUiazLH6+SWDJCh1fQVNiKgaHLXlY6vO7W/
         cdjf95wdC7m+IpXiXMrUqxD3WZVng2GUkXt8H/YEuy8WtKiRq/pMEFgtNh71FTkAJy5g
         TwQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=uAGNj/k9sxhyWPF4gW8v9ANxItk70JmBhK3Bz890W+M=;
        b=edzOQAFfiHNXTOY9SS+LdKXrFxMTcTXC85XAeToYA30b7QA8C+75slzoykltncT3qf
         6GT1GoMx9iVmINf6eSrGHQ4A33DCXQqeNBOWtyW+MRa/HNYHtf6taqvpYjSW3aQhVA0R
         fwoQm8sHI+45AfosJGUABmRUSbE4nH9+3N8d534Zb2gi0+2+nrnmh8cRBWMofYQkzNM5
         TGNdQiwaX5q7RHY6tRh4SGQGZ2CbjGV/Rfevmqt+F9y/i5YLLhk/kWlApG8nvOpVbiKp
         sC+/oQRNJPKERQyRl1wHdsNKrBphNmUU9y5CcGlwmHeS5b63WIeYVDL6MwU9DX7CopcE
         qyDg==
X-Gm-Message-State: APjAAAWeqs3+f17q7EJJXYAmrQr1zvvQkvENNtvIrrhodHkkkx7t+Jy0
	fdGyXXaoZrT2bzMTUAQs/srlVQ==
X-Google-Smtp-Source: APXvYqw0EhdXHc1wpLtFj5TejUK0OxSVjZ2aoiu/qaTO83bFRR+7CanolrCjPltbXW/VvIZh7EuyQg==
X-Received: by 2002:a37:4d0c:: with SMTP id a12mr15819201qkb.214.1567178731214;
        Fri, 30 Aug 2019 08:25:31 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id l8sm3559996qti.65.2019.08.30.08.25.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Aug 2019 08:25:30 -0700 (PDT)
Message-ID: <1567178728.5576.32.camel@lca.pw>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
From: Qian Cai <cai@lca.pw>
To: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Fri, 30 Aug 2019 11:25:28 -0400
In-Reply-To: <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
References: <1567177025-11016-1-git-send-email-cai@lca.pw>
	 <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-08-30 at 17:11 +0200, Eric Dumazet wrote:
> 
> On 8/30/19 4:57 PM, Qian Cai wrote:
> > When running heavy memory pressure workloads, the system is throwing
> > endless warnings below due to the allocation could fail from
> > __build_skb(), and the volume of this call could be huge which may
> > generate a lot of serial console output and cosumes all CPUs as
> > warn_alloc() could be expensive by calling dump_stack() and then
> > show_mem().
> > 
> > Fix it by silencing the warning in this call site. Also, it seems
> > unnecessary to even print a warning at all if the allocation failed in
> > __build_skb(), as it may just retransmit the packet and retry.
> > 
> 
> Same patches are showing up there and there from time to time.
> 
> Why is this particular spot interesting, against all others not adding
> __GFP_NOWARN ?
> 
> Are we going to have hundred of patches adding __GFP_NOWARN at various points,
> or should we get something generic to not flood the syslog in case of memory
> pressure ?
> 

From my testing which uses LTP oom* tests. There are only 3 places need to be
patched. The other two are in IOMMU code for both Intel and AMD. The place is
particular interesting because it could cause the system with floating serial
console output for days without making progress in OOM. I suppose it ends up in
a looping condition that warn_alloc() would end up generating more calls into
__build_skb() via ksoftirqd.

