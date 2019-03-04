Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E06ABC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 14:09:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D53820675
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 14:09:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="iwOmvDFJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D53820675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CE2D8E0003; Mon,  4 Mar 2019 09:09:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 257C78E0001; Mon,  4 Mar 2019 09:09:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11EBC8E0003; Mon,  4 Mar 2019 09:09:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8DCA8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 09:09:15 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id f24so5147009qte.4
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 06:09:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=XeUZ0bSuaagpODDaNgkebhSpO4mdjSfmcYJ84JIvp08=;
        b=YQY7IJvGEs8SQ/q9Gc+njeVzqrUeEnQ+igrpesO/M4DZgW5CJ14nq+Oluo/urzEquq
         qmMupg7rfCb1jt5nG5o2+/vIiL1oMTaArH/1TdwffGkZy4QBB7CLOOvyDxGyNwTeEF/p
         nUCFpQWVBtk5916Uq+14C63z/WIVnuT0tOa6dGsCfI+boNT2cDuSb/QNqSSfiB4k14Oe
         Uww2Uba3PuDQ/4T+NSK5qOl4Qf8DsW1gOKWXepUw6ng3ls1LZkYJKs6/M1Y0bgp3JK+V
         5YYao4uMnO6cEXl53w8Qp+H9qxP9jdzTnLm4ZJqNAJjSNLhlgOE/IMpRfr7mVxuL8+4F
         jhSA==
X-Gm-Message-State: APjAAAWksasKnqHB9mPOQKw5jHxrusNDa7cHv1oEHNbHrVzHCpQqnKPa
	yQ8TrGSC0ZXdDl0J5tblwyTGPT8TGwLQUDNQhoA7UnjjMMTmpArrvfmTH+tF+021N0UXLkFO9qr
	qEzOCtNQTiV64hOX2ncktCHcFzYU/IlrF1fXR6/j3BfFOUgQTXd1FHTQJLtWh2d6n3rdybi0GHe
	Ids3iQ8Xjagn1zZ+xBZC3STbX4D+Ceo5hi/hV8Bu/r5WenyTu1P2W4/JxaQbtqHmE0F3rn5u3qV
	soE2X6H93urjzTQuqk8aTEUOsetTF8mzNG0xVhOOrGNi7NATS/MhTaw7+6gZgZPVbp55dPdubZc
	0WO3v8c0WHN1XBtnljJBGKy/EBTEElZ9caEFG2T12HpHZVBKrRjVC3wixRlgKEAavvBYhw5/GG6
	t
X-Received: by 2002:ac8:354e:: with SMTP id z14mr14853555qtb.131.1551708555524;
        Mon, 04 Mar 2019 06:09:15 -0800 (PST)
X-Received: by 2002:ac8:354e:: with SMTP id z14mr14853492qtb.131.1551708554601;
        Mon, 04 Mar 2019 06:09:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551708554; cv=none;
        d=google.com; s=arc-20160816;
        b=G8OYfGHZvroQMCKejYFRa17G4+LZJosMbT+F1MoTMVjj8ihqG3sbgJBxSsWby0fwUN
         fl78QnruroZi8CAEA9fBlQwOFdFt0gx2dwXfdL2jtWzMC1lGbjZY7oz6WALc49dtlKdd
         osmWtQ1E/8cXPfaZyfESjstZgRRDt3wmMZUYM2fi2VLUxKZtTc0mmkOVspkwVc3/yMG5
         eI+0qdcLjBYb6z46NoarMs+5Io82F/wOgSpJ3lfD2RQwg4InF4FrqHISzuWtEh4aUvDD
         0dGcdwudswCPyMQyewx0mIvBHB5yny4Kd+Y4G7pauN7lQPTsXsxYGc0S9w8O5TLXnEXf
         Pn2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=XeUZ0bSuaagpODDaNgkebhSpO4mdjSfmcYJ84JIvp08=;
        b=TgQNp39rJGVibEo9hG0hqRzMSbMxyTmrcMwRIM+DYgNK8JL+FyDkXNrRbDJAAkgKKg
         jJVTxTFN9dE9GJdjDeDsrnXy12EJ3NC6HFfmEvrDk3ipsMXI65c2dczErf+Mu24QBH0J
         qomt9hm8M7OuvaOuhtUtR1mK0NjePUY3zCwRhBx1PU1TelPtBCMIulpMSU00+4rbre9Y
         1rvesWxNCXZDYnBWzFuB8Srq8Nn0Z5O8CN91VVB0X1fZbNDD2JKyHaPimpOCsMsOtmJX
         7OIRB5TjUN3J8GZTkPbBH6c9WDyhQEHV6MIv0oGQhW9vcDA5s/0X98ckImXzh0bIExmN
         mQ2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=iwOmvDFJ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j18sor6999452qtc.70.2019.03.04.06.09.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 06:09:14 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=iwOmvDFJ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=XeUZ0bSuaagpODDaNgkebhSpO4mdjSfmcYJ84JIvp08=;
        b=iwOmvDFJyslQ30B84EdbQ9EcU0e9z0nlF7veasjUif1D/2vlMYSgIj9v/R4afuGm66
         wCCf6sJ25kH2fJMu3lsfy6eAZm1KlksFQih5qpltw+Qr8dshZKnHMCFEs/Esu3jMh+sH
         nGUFsAVx5cBV11ddc0bK/Q99QD0unMqIVe0ZaxbglNDwwjg9YOW/YBCRD76CseCKJhkN
         FvmVTKEPJF5GRRemIlvy8WaDd61LFbb3WBUm1yc6hXH+Wsa8u4iMROz9FF+p3J39PPMT
         dnPjt4HVnZGB90xEwwgOM/6+M+5ckD7AKD2KV1U1Lt7nVlbuMLMJGMjpyGF0n1VWGGAz
         58bA==
X-Google-Smtp-Source: APXvYqxebk4cygCw66b8m5/eWF71BIN2+jlrN1rpbLDw4AjriPIoka3S/L5IeqOWgi//Y9xk4xIwzw==
X-Received: by 2002:ac8:67ca:: with SMTP id r10mr14668266qtp.134.1551708554226;
        Mon, 04 Mar 2019 06:09:14 -0800 (PST)
Received: from ovpn-120-151.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id x25sm4186313qtx.71.2019.03.04.06.09.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 06:09:13 -0800 (PST)
Subject: Re: [PATCH v2] mm/hugepages: fix "orig_pud" set but not used
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, Linux-MM <linux-mm@kvack.org>,
 linux-kernel@vger.kernel.org
References: <20190301221956.97493-1-cai@lca.pw>
 <CAFqt6zZr8ZCM6_7QDzDEf=5gH=+EkaumXk86X35dGTdn_SLvvA@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <935fc484-70e3-ed7a-ed82-329529e0e280@lca.pw>
Date: Mon, 4 Mar 2019 09:09:12 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAFqt6zZr8ZCM6_7QDzDEf=5gH=+EkaumXk86X35dGTdn_SLvvA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/4/19 7:02 AM, Souptick Joarder wrote:
> On Sat, Mar 2, 2019 at 3:50 AM Qian Cai <cai@lca.pw> wrote:
>>
>> The commit a00cc7d9dd93 ("mm, x86: add support for PUD-sized transparent
>> hugepages") introduced pudp_huge_get_and_clear_full() but no one uses
>> its return code. In order to not diverge from
>> pmdp_huge_get_and_clear_full(), just change zap_huge_pud() to not assign
>> the return value from pudp_huge_get_and_clear_full().
>>
>> mm/huge_memory.c: In function 'zap_huge_pud':
>> mm/huge_memory.c:1982:8: warning: variable 'orig_pud' set but not used
>> [-Wunused-but-set-variable]
>>   pud_t orig_pud;
>>         ^~~~~~~~
>>
> 
> 4th argument passed to pudp_huge_get_and_clear_full() is not used.
> Is it fine to remove *int full * in  pudp_huge_get_and_clear_full() if
> there is no plan to use it in future ?
> 
> This is applicable to below functions as well -
> pmdp_huge_get_and_clear_full()
> ptep_get_and_clear_full()
> pte_clear_not_present_full()

I suppose arches may override those that could make use of "int full".

