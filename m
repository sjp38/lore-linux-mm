Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD1236B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 04:36:12 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o25so108339354pgc.1
        for <linux-mm@kvack.org>; Wed, 24 May 2017 01:36:12 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id r59si23197681plb.87.2017.05.24.01.36.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 01:36:12 -0700 (PDT)
Subject: Re: [Question] Mlocked count will not be decreased
References: <a61701d8-3dce-51a2-5eaf-14de84425640@huawei.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <85591559-2a99-f46b-7a5a-bc7affb53285@huawei.com>
Date: Wed, 24 May 2017 16:32:48 +0800
MIME-Version: 1.0
In-Reply-To: <a61701d8-3dce-51a2-5eaf-14de84425640@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhongjiang <zhongjiang@huawei.com>, Qiuxishi <qiuxishi@huawei.com>

Hi Kefengi 1/4 ?
Could you please try this patch.

Thanks
Yisheng Xie
-------------
