Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA650C04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:17:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7F6121479
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:17:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7F6121479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E17A6B0005; Mon, 20 May 2019 22:17:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 392A46B0006; Mon, 20 May 2019 22:17:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 281DB6B0007; Mon, 20 May 2019 22:17:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E449A6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 22:17:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r48so28200861eda.11
        for <linux-mm@kvack.org>; Mon, 20 May 2019 19:17:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gIaDLbma2Hx3UaN96vD5pn8bmA/Ju1YIevayQJghav4=;
        b=rkKYcUIQoybUk176caZBaqVTlb3BnRpFY17VcuPvgPmVcLyWMPwk6l5Xo40MegAoCL
         8Ji9tMZeJC7pYY/kdBeQgyQgtEljt2a48za9/HZsMY4qexvO1wMJhS/e7xQ6CnTtUdwL
         ub1aZDRAcCNc4SA8FWMp9F2fDJsp0kHA7+N/5ZzEwu7bGKQSekMYv5DHN5mQs9OHDUkS
         l5BHGUNyOdPs4GN+2tXvHx831DzNE3208ZdJsiLz5f3cXOHHwt2MVv47wuH7UEwKHEdi
         s7S60KsZeyhlivOAAalW0Hb+aFGq7prQk2gtnH1pz+3Eben9L5DbwYXps5Besgq4MNT3
         Ak1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUKEh9w4j2Qs4fBWPfNX8yolb4OfXffV1VC4JApOZ5EMsbKkpbW
	gKTuKDB2JH3Lsz4V1KZoZNIj9oUqxuQMdMj/KeCOI46nqgDoJVX2P0qLNjBMJOw5BHd0itP+xO2
	go84d/avJN1pDiqFN9cDNiDIbgPfuDIRAgK+zo1ly97tXXrHshJMJH6sn78jorDHrrw==
X-Received: by 2002:a17:906:489:: with SMTP id f9mr51896401eja.256.1558405037449;
        Mon, 20 May 2019 19:17:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRQ6JbJPJh52lC8oIggyXstKL6k8a6YZs4NFKrPCsWLz36onW4zojYnj60M1aiVBPEibEd
X-Received: by 2002:a17:906:489:: with SMTP id f9mr51896369eja.256.1558405036817;
        Mon, 20 May 2019 19:17:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558405036; cv=none;
        d=google.com; s=arc-20160816;
        b=BLsVnOR70jA1bLI0NFEjSv9pU+eAFRzIuub3ge+LUhef2NwewlcKeHooXTslE5C2NB
         2OV3kWKFkfqkwPP5dpXAfYse8r+c3i/UZMnjeDPZ/dfAw6iGTQG6PG28d9h7Ntk8JTBN
         Mre9Vi/myj+pxRbO1PhUPw98/CV7E+fJ/oOcAHDrdzPOeBa7DUpZM+if4ITiLN7BTdCK
         9wk9ii+AffuNIrrZsb0mIHWbsdQKlaBDLSYMfA/hcVBxBPkbozA/xq9KwUs4KEuHsn+K
         qSct4l6J0Q+BK0aLIaar0Ujb80PQepaVq7AUx518xM5EZhQyc8pbFyA7gSusxSMjjD8i
         wRgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gIaDLbma2Hx3UaN96vD5pn8bmA/Ju1YIevayQJghav4=;
        b=qV7Q8rV/BVWwmlqJUBbGDKAN0VSRvl25uTpJID568kbdzsToROF6o+jyepXhzY6E3L
         TclhlaYfjOD/omfVm36KZdRuX4yFB+JmseGDlZ6rJAcqwtzJzlb+Jm8gLfsGQsteZpJj
         VMXuhOxZdth4ICRpYC8xN4Wn6XzuBZdhDLF80NSqstz6+YTQOotuS5ojq+60HBJesnD4
         91GUmGjfRLpJeLITHEva2LfWsiNu+fY0zpJ944vXZZoUu6LAJ5N01fMm99igfCJ3vj2K
         CZZQv8E6iP0ff+Mkek8OcNAd3hamV1IvMdWioDzPOb4nZK4GnWmm0yV9QH1ZocHN88/H
         aV8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v9si77280eja.71.2019.05.20.19.17.16
        for <linux-mm@kvack.org>;
        Mon, 20 May 2019 19:17:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AFE39341;
	Mon, 20 May 2019 19:17:15 -0700 (PDT)
Received: from [10.162.42.136] (p8cg001049571a15.blr.arm.com [10.162.42.136])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E36A23F718;
	Mon, 20 May 2019 19:17:13 -0700 (PDT)
Subject: Re: [PATCH v2] mm, memory-failure: clarify error message
To: Jane Chu <jane.chu@oracle.com>, n-horiguchi@ah.jp.nec.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
References: <1558403523-22079-1-git-send-email-jane.chu@oracle.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <f1e4d5e9-e0a7-1a88-f5a5-de9a350e37ef@arm.com>
Date: Tue, 21 May 2019 07:47:26 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1558403523-22079-1-git-send-email-jane.chu@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/21/2019 07:22 AM, Jane Chu wrote:
> Some user who install SIGBUS handler that does longjmp out
> therefore keeping the process alive is confused by the error
> message
>   "[188988.765862] Memory failure: 0x1840200: Killing
>    cellsrv:33395 due to hardware memory corruption"
> Slightly modify the error message to improve clarity.
> 
> Signed-off-by: Jane Chu <jane.chu@oracle.com>

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

