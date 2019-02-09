Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CFDFC282C4
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 05:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B79EB20863
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 05:51:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B79EB20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=acm.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C18B8E00AD; Sat,  9 Feb 2019 00:51:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06FA48E00AB; Sat,  9 Feb 2019 00:51:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9F9F8E00AD; Sat,  9 Feb 2019 00:51:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B80F38E00AB
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 00:51:57 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w20so4362017ply.16
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 21:51:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WyG8srNHcbEVwuVZDQSoQ3GcdjgBKLcULSbZaFzfyuI=;
        b=mt/YPwFOZ+9lIU4q50NFBFnnn78jPgWg1L9Bp4NiFiXMFQ3uzviAkFFSopZLnxiKy9
         7PwAUQq4PoUd/fOciD3jWHnNjEDYyzYvQGkgWJ1+mhYH10oB74SJRwIL1VpqOp9xDKPN
         zmNMitzE3CrzOMF2Mp+oMYH/pCrUR9fy7psExQ+IT9jHKTXJtnobfyWpz9XI4IT3nC37
         1i99cFJO95jcDqJf7GTwu4vkp2ot5X6zWoBY3WpcrEysfJMtfGDobEQfgsBWmRXiYoL7
         Bb/lUO0W8CRF9kqttZd3Kpvbb7ucT422mbvxEPbgI7ei1crQQpBjcPrVaJvwXtWSA3oW
         1UcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Gm-Message-State: AHQUAuZzKFpEJrDbSv67frHYCh6kIZZ0y3n0UZsEYNeblkDiztnInOrd
	qYaFXVjnnWy7jlUSZDM6+zw3ADbp/xeGLwroQGzuqkcraR7dgMMXSy25BqZYC4AGmcSeVwtZ7tL
	cxhPHVUp5SN4JG9M8EIEjHhHjEswmCN9VvpIzA+B6VAbWz9KhzDGsbuVy2tWsPe1OIulOvmkTZt
	EL2XuSA/PJzqD8kc1yZqeAeqPBMtZSH9LWbdszpcFICfWXTr/rSt29Jb62/OIpWOHUXGZA+nvAk
	ri4F/1Cnxla2EJE8NWFCDa74LokFNhPoUBc2ij64JavRShl2JQ2NWFC4tDCVdZx/xBSKe/rgF5u
	fnzEdHER7uiy714RG5YJLttTdWm9gNj1K08JwZrOX/fH/BxzjpM8W7ilFo9xuusH7WKfnn6sVA=
	=
X-Received: by 2002:a17:902:2e01:: with SMTP id q1mr26298789plb.97.1549691517329;
        Fri, 08 Feb 2019 21:51:57 -0800 (PST)
X-Received: by 2002:a17:902:2e01:: with SMTP id q1mr26298748plb.97.1549691516360;
        Fri, 08 Feb 2019 21:51:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549691516; cv=none;
        d=google.com; s=arc-20160816;
        b=1Bp5d7QeBFCYgVXxmjhb/IZ9cLOxuuaUpAyKAx3lM2DIkSfKQzJznqIg/ZD4z/Y6pL
         WV0mvOoKFiZHslJJoKH/CJ9W4XtM1mGZuP8R4wS12mMCmhVjbYd8D9Rba/2MeuRc0IrN
         vgl0NRwGvQM4eg6otk2SAsxDwl2OKVXnPuRPBvgj0+RJ5M5G41rnWi97n1GNaHE9wQ/P
         3RvITN3VejY+IXypx+fzCJLvAbR9UPNqeq+HsFKi0taVXKuNEZ8AUwvFM6DZrr+iUpJ9
         4Q5oE9o+S8wLAQLQwGGZQMMyZPEkRxNefFjAp2LXSVwccQvR2eIV6s6CJq5gK+tT7crs
         h7iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WyG8srNHcbEVwuVZDQSoQ3GcdjgBKLcULSbZaFzfyuI=;
        b=HueWQ50HzDDe3I7CwWUvtugQvR0WTOKd71TplgiGvHVPLwYHS0cBqtuU7FlD8Ze5ab
         R9ZYtkXH7jxlMLh2znYWjQFjvaPlEgv32i2zge4R33PAWH2cgCu3J78nxJB+3n94X0Dp
         F0osFi4Hvpu3a6yJ6A0ZjzzQT4CvKUF/k0fvtP8V1EcsXwP+s3lXEC2XasKouZvH7tnX
         uXh25npwjEN5r0dFMO54UCr4UtTr2CoMIze871tOcG8TWNlgim/DAvyftdCMHXuU+X+q
         UvijNyXQXSF2L0In9ZkkaQlmfQz+m2Lgj5KEEErAfrILXSLuyoulhwVXEasm0KGwJD52
         YeWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor5870110pla.7.2019.02.08.21.51.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 21:51:56 -0800 (PST)
Received-SPF: pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Google-Smtp-Source: AHgI3IYUPm+kG7/kjLgc/FEYfvgGlG7AplPXYkEWUwQ70XXWjTkhs+DUwWRij/hBCZDGYIB5a4MiDw==
X-Received: by 2002:a17:902:bd97:: with SMTP id q23mr12566160pls.284.1549691515739;
        Fri, 08 Feb 2019 21:51:55 -0800 (PST)
Received: from asus.site ([2601:647:4000:5dd1:a41e:80b4:deb3:fb66])
        by smtp.gmail.com with ESMTPSA id 15sm6553635pfs.113.2019.02.08.21.51.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 21:51:54 -0800 (PST)
Subject: Re: [PATCH] fs/userfaultd: Fix a recently introduced lockdep
 complaint
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>,
 Andrea Arcangeli <aarcange@redhat.com>
References: <20190209010308.115292-1-bvanassche@acm.org>
From: Bart Van Assche <bvanassche@acm.org>
Message-ID: <204b2c05-c074-4da5-48ad-e610fae3324d@acm.org>
Date: Fri, 8 Feb 2019 21:51:53 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190209010308.115292-1-bvanassche@acm.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/8/19 5:03 PM, Bart Van Assche wrote:
> Avoid that lockdep reports the following: [ ... ]

Hi Christoph,

If patch "aio: Fix locking in aio_poll()" 
(https://marc.info/?l=linux-fsdevel&m=154967401921791) would be 
accepted, would that allow to revert commit ae62c16e105a ("userfaultfd: 
disable irqs when taking the waitqueue lock") instead of applying this 
patch?

Thanks,

Bart.

