Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09DDEC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:27:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD9BA2085A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:27:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="kC+fcX/d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD9BA2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DA926B0003; Tue, 19 Mar 2019 19:27:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 188806B0006; Tue, 19 Mar 2019 19:27:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 029786B0007; Tue, 19 Mar 2019 19:27:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1E5C6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:27:00 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id b1so558730qtk.11
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:27:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=p0h+sIgjeUxau/Nsm0Ajru2ZRtZp01Kp4DUd8gtQGj8=;
        b=P9+Xo6VG+dWrVgS5nxbE5AeFinjoFwDW8pfTtZL9unK/yCWUX7OLKXM3RiOzmJNoLT
         +raapdfV27frdc9vmAuO+uNytoHqrrBQYnVTBJs+TbQRm3JkyCHyYsVAULOPEQjsiZwW
         eTbjwyqGCjlo/0cQG8Ku+WO8Bxdc9aNXFTyHiqrh5XAKcks4mGTV8L/HjdDM3ZTGTJ/t
         tNwf0ZZJIQsx7HLVNtRB9isgfJkwTDtc80c8ynIQQsgOIvdNfdoY9aHRC1ZqImbd+Ulk
         cAs00Aqu0X5sxuPPbY45knJu7/Y13gyUISMN9pscDwf86KnhbfsJShxCJKOlVDdjKLOn
         JPlw==
X-Gm-Message-State: APjAAAV7cbA/yhfzeNgMWUggVDfGfiKKIG4aCyuzNRqaDdxwXxhaPVwm
	WLNlwEp1YkF295PsHIQxJIRWAytcjCtKeB1nKg4JTzNjIhC8OU/hQ6DPov6GXNC1R5CzoOzOZkT
	sZE/kgB4lDFv7v8RBIufWB6wH9TkOjukoBcQNJ8lsE6dPEcHuPpegIZeKET4tyPN/rg==
X-Received: by 2002:ac8:30bc:: with SMTP id v57mr4308818qta.26.1553038020600;
        Tue, 19 Mar 2019 16:27:00 -0700 (PDT)
X-Received: by 2002:ac8:30bc:: with SMTP id v57mr4308787qta.26.1553038019846;
        Tue, 19 Mar 2019 16:26:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553038019; cv=none;
        d=google.com; s=arc-20160816;
        b=M101gun+0eV8QbEtyiaMHWmLel5PKaFausPffrxly6AF/4nft503z0UJ3Fr8C+XUuL
         wJ159Dmnb38B9t1POxtjOSkgK0B5anxgVRFWwnb8g2+Y+1mRvOBj5s/QMrDheK7XM7sw
         v5OyGzipag9f3Dmt1Y3gsMCrCS7OKmFqilzfBlcAPHKUmVjhN201PxU9oZrfsjaE5pLe
         ttFZnb1LLf2kFcUqSvtRSVZyGejcD64ngLGyvxAUEA845NiQPq9MvCgbany8Z+wpSouV
         JLZqUrTDy5/oPxwBAApwTNGBnDYrWj641jAnwL4+adX2TQUXMKwjy5l86A+PEUqjVZwH
         M+ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=p0h+sIgjeUxau/Nsm0Ajru2ZRtZp01Kp4DUd8gtQGj8=;
        b=e5sJD2RUVe7+LX6L5vSKLupJEbVKpDGrrFHSUGjaCkM5P8lYtVokJXrUOZ0S7GNb3I
         G14ffIb/y0l9ERcLocmRuuoOBdMoSBONzulh5/OMuw/jKStl7nXQxHW6u7j3XlFSp05O
         CONw5eq2maGI+7xqrZKIsjM3zLlzJh2RDhs7Sm5+9TrKy7j2ct3XJ62bneZ8a2T1KPVt
         BtBtUrXS5FB+oYYlPATmWvE2uc3m8G1hKNRQWHusVKVZ9yjwZO/iYV4qbZYY1ff+AHYb
         Z7dI0xGIJZAeizhTM7J2T0TG/SgbbzFwPx1MARbM6sodP2zjXDWJAs6F2mPTbIP1R6Vw
         YuKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="kC+fcX/d";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 5sor691105qtt.46.2019.03.19.16.26.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:26:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="kC+fcX/d";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=p0h+sIgjeUxau/Nsm0Ajru2ZRtZp01Kp4DUd8gtQGj8=;
        b=kC+fcX/dw30pY8bLnJjAX+Gr5hLkcCzKimVaPwGYz5jY4a0orPi09KJKsN2pa9sVlx
         RymJ4U6b2Vsejh5i+riCMNXQCihb85eSreELm1GSe9URyrzftdOwyp3XR+xlb+pUFVp5
         8wlIhpUm1rRfz7t/3Qc8Agh2D9nhBlRT1HC6XwA7ZgoQkeiMpRDjURcBnk0Cfmn2Gmtx
         5+hWORxQlmP7ob4K4rvfoVvR5Pu0DF1sze5LZ5cSIdMC0Oqe0e0UGu1cMH5dH0gzvV/0
         qzXruuremf8gQ9K0sRsXp5CwbpYAbEn6L7b1O4oIqOPehYLJpfF1A4cteK4h/E9Xxk/q
         ZGyA==
X-Google-Smtp-Source: APXvYqysFsl4AJeqVYo7Rkwd/feXF7JhwIOa1yuC8FnWDM/F4Wm/7dDfGwuNzML7hAiYvOOIkK6s2g==
X-Received: by 2002:ac8:3a63:: with SMTP id w90mr3355888qte.233.1553038019515;
        Tue, 19 Mar 2019 16:26:59 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id n1sm299145qkd.28.2019.03.19.16.26.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 16:26:58 -0700 (PDT)
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
 Daniel Jordan <daniel.m.jordan@oracle.com>,
 Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
 linux-mm <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <20190317152204.GD3189@techsingularity.net> <1553022891.26196.7.camel@lca.pw>
 <CA+CK2bDhB8ts0rEc46vVT-mR8Avx=DZAdyMTzxqOD99MP7dOEQ@mail.gmail.com>
 <1553024101.26196.8.camel@lca.pw>
 <CA+CK2bA6J_BT9C=-ohezTj4L9TV61GCi9MsKbhGO4ZtEBvdkeA@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <15f16d2a-bf90-ede3-0803-821da3699b27@lca.pw>
Date: Tue, 19 Mar 2019 19:26:57 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CA+CK2bA6J_BT9C=-ohezTj4L9TV61GCi9MsKbhGO4ZtEBvdkeA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/19/19 7:13 PM, Pavel Tatashin wrote:
> Thank you Qian, do you happen to have qemu arguments that you used?

No, the KVM guest was running in openstack.

# lscpu
Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              24
On-line CPU(s) list: 0-23
Thread(s) per core:  1
Core(s) per socket:  1
Socket(s):           24
NUMA node(s):        1
Vendor ID:           GenuineIntel
CPU family:          6
Model:               79
Model name:          Intel(R) Xeon(R) CPU E5-2690 v4 @ 2.60GHz
Stepping:            1
CPU MHz:             2599.996
BogoMIPS:            5199.99
Virtualization:      VT-x
Hypervisor vendor:   KVM
Virtualization type: full
L1d cache:           32K
L1i cache:           32K
L2 cache:            4096K
L3 cache:            16384K
NUMA node0 CPU(s):   0-23

# free -mt
              total        used        free      shared  buff/cache   available
Mem:          41214       36331        4745           0         137        4499
Swap:             0           0           0
Total:        41214       36331        4745

