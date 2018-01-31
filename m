Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68A016B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 12:09:54 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id h38so11151349wrh.11
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 09:09:54 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id v37si1824600edm.114.2018.01.31.09.09.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 09:09:53 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] Killing reliance on struct page->mapping
References: <20180130004347.GD4526@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <111f49c1-02d1-3355-e403-a8f91c0191e2@huawei.com>
Date: Wed, 31 Jan 2018 19:09:48 +0200
MIME-Version: 1.0
In-Reply-To: <20180130004347.GD4526@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On 30/01/18 02:43, Jerome Glisse wrote:

[...]

> Maybe we can kill page->mapping altogether as a result of this. However this is
> not my motivation at this time.

We had a discussion some time ago

http://www.openwall.com/lists/kernel-hardening/2017/07/07/7

where you advised to use it for tracking pmalloc pages vs area, which
generated this patch:

http://www.openwall.com/lists/kernel-hardening/2018/01/24/7

Could you please comment what wold happen to the shortcut from struct
page to vm_struct that this patch is now introducing?


--
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
