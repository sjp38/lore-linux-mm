Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7546C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:08:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7472E20863
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:08:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="YFUIh2Ny"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7472E20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0F286B0003; Mon, 18 Mar 2019 12:08:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D96616B0006; Mon, 18 Mar 2019 12:08:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C391A6B0007; Mon, 18 Mar 2019 12:08:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7236B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:08:39 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id b1so16715838qtk.11
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:08:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=SeaG/ieCIup+ytLBoCmxEfAvdTy8qpZOugI3NWcweM4=;
        b=smhNiWMCPEN9HROMjtTlvt+pThFi5/+KaQFgOvR3sQnNtWfbHrJEPtGjKYVVZdlW8e
         49A1418/U7gQNX8qP1CoiIjbiypv9QYvfyc3QFK9UINyRZCmx1b+yUqgOXxWf4wL58Oo
         50XCIMoL/+70F5ljLviJp2rsmfgqgS21peqLw5LHvDR1zcA9FHa+FxwslyEuB1/t11Zh
         /X/KVFXXX71b4Jdlx6ubyXQnJyiMmDn7STMJL0wugu/BSyCGjyrSevkjAqqUghbBEsU2
         qTHOnSoV8oYgeUwjVqRrmaF62TzCnFlEExgGdel+yN4+vP7Ei3df6HM2OM5qSJV9XGry
         yyLw==
X-Gm-Message-State: APjAAAUPkadWoKA5d+19AlSphQTl23Dp0oDwwfVsI3Yu4nmKMgZIevAP
	KV2Si33KEfZEGiQMlnuFi0E+z8WUnoqvtbOdWebjaf8XBGC+i5+bMvoZBqOnOvXSYQSCXKveitT
	1EVyMeHRJ5nQcmViBmf0Sd0PntRN9f5BxCiMflVQTCdpXeZ8GPU46AVrcoihsfqXgeA==
X-Received: by 2002:a0c:9ae5:: with SMTP id k37mr13996892qvf.128.1552925319410;
        Mon, 18 Mar 2019 09:08:39 -0700 (PDT)
X-Received: by 2002:a0c:9ae5:: with SMTP id k37mr13996823qvf.128.1552925318533;
        Mon, 18 Mar 2019 09:08:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552925318; cv=none;
        d=google.com; s=arc-20160816;
        b=jRYDfOF+DKEkdnIgZfOa9VDRpKXlSjYx/HH4hYHD3bcJdp3hSwu+scbl7RoFG6BQM4
         v7pDpDG0cr3DF9oIn3wTQTv/yFmogbR1gT/k0R2iS68GzEBf3YafRvtq+UhUe/Weuv0e
         BLUHCAcKvKriHommdGi11nbdeki9NuP2eLZvHQAGNLWGOyTDTLa3AsYAJ/FakQ9+Cl7p
         QjbGKw1WXyThbLLogQmhPhtPSSdhFPjDpUUXbBcP9ymNxcqX8qI9Ab5LOMCxYezDkskw
         LGGMuZV3cqZKLPWV6DuECVcrAxze5rPY7UQT7XtNxbHO8Qaa/4ODosJ6jKLoV4J6aIX4
         GbiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=SeaG/ieCIup+ytLBoCmxEfAvdTy8qpZOugI3NWcweM4=;
        b=djRF256Zyctm+i/8ZKTZNcMVLBB2a90sJE/KyRMeOEvf4+/gD27Qbl4RJpPRevlC18
         Ua/XahIq/gxIJQYAscce2l1KG5L7VNztofLrDschFGs1XA7zkd7QAEWcuxAQbR2LcCOn
         k999lrwohoGPy3OQPjFVDdrbaikfiwKZ3ll/fEsfgJCSCNqpUE3ap5ttAlOUjCWwurtP
         +jPErPo4MT/8q22EP+AEUkdwbFdrtBrnBzUHYlYuJAitTpzyTabl5Li5ka8fZKm/CF42
         oVtEIHRSjsQ9OUN+2YC8gzmhcK4K3fWIDTxhEO32CDpUEPJKFPoCF4VGh1NfEN0Rlskb
         A+UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=YFUIh2Ny;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q11sor4098658qtq.28.2019.03.18.09.08.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 09:08:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=YFUIh2Ny;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SeaG/ieCIup+ytLBoCmxEfAvdTy8qpZOugI3NWcweM4=;
        b=YFUIh2NySihrOIJC5HjaKpZP/6aMx/6HaCbFcs4dTtbJQ2GpUiY9bGETbR34q3+vDU
         mIMztF/7f0FtWGYbGdtcXsljG9pj4iTlqhFIYoR/FAatQZ7rNZEBAFy3pu4G2iMyAUep
         uP95u9oOqGx3hR1Wp3GmQk3efLJ1EgDpV+UxtbYcoSxMkY4DHH9zxAIZoB/nE7Fel4Nj
         ecdwlTCyFpCEoXqmd+XLXNclQ0Ol/gxlzrN+JBFo8axN3LRdDOm03PdQbDtU32qOcrQW
         GJZD7D1ZM3OO484FUPspecrcsAHYF3PcO1ysPZij/yZ44E6BesfKFcc/0n1z0TY6cl3j
         M90A==
X-Google-Smtp-Source: APXvYqzC+iaG/0MTmU9GCJKHDXMo8T2dPC9ty/sz9GXH5iWWjfFcoIQbUaes/BqZHd1G6f0Zd2bTVA==
X-Received: by 2002:ac8:28a8:: with SMTP id i37mr14453545qti.215.1552925318118;
        Mon, 18 Mar 2019 09:08:38 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id y21sm7436001qth.90.2019.03.18.09.08.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 09:08:37 -0700 (PDT)
Message-ID: <1552925316.26196.5.camel@lca.pw>
Subject: Re: mbind() fails to fail with EIO
From: Qian Cai <cai@lca.pw>
To: Cyril Hrubis <chrubis@suse.cz>, linux-mm@kvack.org, 
	linux-api@vger.kernel.org
Cc: ltp@lists.linux.it, Vlastimil Babka <vbabka@suse.cz>
Date: Mon, 18 Mar 2019 12:08:36 -0400
In-Reply-To: <20190315160142.GA8921@rei>
References: <20190315160142.GA8921@rei>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-03-15 at 17:01 +0100, Cyril Hrubis wrote:
> Hi!
> I've started to write tests for mbind() and found out that mbind() does
> not work as described in manual page in a case that page has been
> faulted on different node that we are asking it to bind to. Looks like
> this is working fine on older kernels. On my testing machine with 3.0
> mbind() fails correctly with EIO but succeeds unexpectedly on newer
> kernels such as 4.12.
> 
> What the test does is:
> 
> * mmap() private mapping
> * fault it
> * find out on which node it is faulted on
> * mbind() it to a different node with MPOL_BIND and MPOL_MF_STRICT and
>   expects to get EIO
> 
> The test code can be seen and compiled from:
> 
> https://github.com/metan-ucw/ltp/blob/master/testcases/kernel/syscalls/mbind/m
> bind02.c
> 

I am too lazy to checkout the repository and compile the whole thing just to be
able to reproduce. If you can make it a standalone program without LTP markups,
I'd be happy to take a look.

