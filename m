Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D11DC48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:43:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C59F2208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:43:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C59F2208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51E206B0006; Mon, 24 Jun 2019 00:43:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D19F8E0002; Mon, 24 Jun 2019 00:43:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C03A8E0001; Mon, 24 Jun 2019 00:43:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAB26B0006
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 00:43:40 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id h67so4839104oic.0
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 21:43:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject
         :content-transfer-encoding;
        bh=EDgzWfYbWE7FfAyTzEFHD+rdYCt21ByTIyQ+U2aPwPo=;
        b=SycDqgbRsN6kbuTQ8MhO9rUtuwXAxJvECkH3BAu4UqqJVHHLqI4K42AL/xMtjmhw+F
         DF5yS4/DOFZCfx8Yk2sJNgONy5vRjKsDcf/6FHcU0YV+HMbURpPgk691xS2VSElPMt1x
         ZoQxYBji3J7DCCaZv5szPJntLHXhFNtErY5cDGGzQtOjFohCcLBWiXTJ2ODQXJnyurwy
         cbVHQdCpHf0lCwnAQH44v5yWbiqGG37GzLhYTvxWasMNs0dRBHfSV05KFSylzdXD1Mbs
         f5KO9/uW2iFOeDaieJ8cBY5nvMGmboYpmRzf4hQrer2e+n5OV8IdtQNshlCMtMRSMHkk
         7d9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAW38iXRW4IBROLhd6hEjBt7GPKmtprY70KdsIgBfZ7W1AwMJq/7
	1owcg4170Nn3Omb0yKMl9KmAT1bARKhJLp/pwpcY0a7ShbOIjpRkHFFEgNB2q7spsV76yt0ghhI
	vNdzGowqmXienAUE26efykN/yEQsdZcRHxrunrmFvdpx0dseH7gK1qC5R1znSzN9q6w==
X-Received: by 2002:a9d:4c17:: with SMTP id l23mr12939008otf.367.1561351419545;
        Sun, 23 Jun 2019 21:43:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2nl9CKaupK88oQHKpf2QGbEK4C+lh8AJb8g/jxz+A1+vKOSKZUxo10EvxLXofGF0gnheR
X-Received: by 2002:a9d:4c17:: with SMTP id l23mr12938988otf.367.1561351419034;
        Sun, 23 Jun 2019 21:43:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561351419; cv=none;
        d=google.com; s=arc-20160816;
        b=KS6mqsV6TNUfUBDjtd73Xq8k8IdlnsWSG0x229RZoxg40BpjVkQGgVvCsbi/3QVXhs
         UpfqLLamvBq4MQHa3MZ0dwG1vBWZyOweegX36R6LGyqbCN38tA/jS9sa7habAoeMTcR/
         XcDczBeRAjW3H0+2D6gBnGoz3GsvArzH2OLBrVQq6t2F/rp2dKyAHcNtP7AOYhqLsRdG
         6ExnS+KfHJZGAc26HwSI4ZuYuhH8RNUEkKssi7Itk1Ve0JP9Mgro5zqO32Gfsbqb2eOA
         rWseUjjXWqWTqXuZvcLEY2WJBXR3aMsYfhj3Ktsgfd4reBWb0iz0ckuPh3bx+/5LwUF2
         q62A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:subject:cc:to:mime-version:user-agent
         :from:date:message-id;
        bh=EDgzWfYbWE7FfAyTzEFHD+rdYCt21ByTIyQ+U2aPwPo=;
        b=K5lrUK8C7wZfhQd98fGyHCjQ3tOjzYgM1fYHW7swtMsbIfoj/kd4M29/rf5I+B7dqv
         55sXskbs5IaYsgQdqs3wXYa+K9vTgTdOG72Kg4OtPVX0lS49lfvbiQOoCCgq/hrz31Mu
         C5963V0OHs8O5l5a29X4xjdBqcHLwFSOgfmFjDGsWB6e6w/PJze1nxG9c4yOBTrBDZsP
         ppac9XwZ6Hq+dDgDx7vrfaJaFBPLvjoURINGEFIQVA0wmsTBmclQUyiQAlz7itYt5K92
         GLkd425PEY8PL52IiTiGZ9kjphv5z2Cm0IVwk2qn8tnLjZ094QS7eF1wJOBPwdA+Qber
         DuLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id m10si5954833otm.318.2019.06.23.21.43.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 21:43:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 469EFA42202E886EEE25;
	Mon, 24 Jun 2019 12:43:35 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.439.0; Mon, 24 Jun 2019
 12:43:27 +0800
Message-ID: <5D1054EE.20402@huawei.com>
Date: Mon, 24 Jun 2019 12:43:26 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>,
	Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>,
	"Vlastimil Babka" <vbabka@suse.cz>
CC: Linux Memory Management List <linux-mm@kvack.org>, "Wangkefeng (Kevin)"
	<wangkefeng.wang@huawei.com>
Subject: Frequent oom introduced in mainline when migrate_highatomic replace
 migrate_reserve
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Recently,  I  hit an frequent oom issue in linux-4.4 stable with less than 4M free memory after
the machine boots up.

As the process is created,  kernel stack will use the higher order to allocate continuous memory.
Due to the fragmentabtion,  we fails to allocate the memory.   And the low memory will result
in hardly memory compction.  hence,  it will easily to reproduce the oom.

But if we use migrate_reserve to reserve at least a pageblock at  the boot stage.   we can use
the reserve memory to allocate continuous memory for process when the system is under
severerly fragmentation.

In my opinion,  Reserve  memory will relieve the pressure effectively at least in small memroy machine.

Any ideas? Thanks

 

