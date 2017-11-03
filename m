Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 11BF46B0261
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 04:33:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 76so2169160pfr.3
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 01:33:09 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id j13si5468720pgf.700.2017.11.03.01.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 01:33:07 -0700 (PDT)
Message-ID: <59FC2A47.3020103@intel.com>
Date: Fri, 03 Nov 2017 16:35:19 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 0/3] Virtio-balloon Improvement
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com> <20171022061307-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171022061307-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On 10/22/2017 11:19 AM, Michael S. Tsirkin wrote:
> On Fri, Oct 20, 2017 at 07:54:23PM +0800, Wei Wang wrote:
>> This patch series intends to summarize the recent contributions made by
>> Michael S. Tsirkin, Tetsuo Handa, Michal Hocko etc. via reporting and
>> discussing the related deadlock issues on the mailinglist. Please check
>> each patch for details.
>>
>> >From a high-level point of view, this patch series achieves:
>> 1) eliminate the deadlock issue fundamentally caused by the inability
>> to run leak_balloon and fill_balloon concurrently;
> We need to think about this carefully. Is it an issue that
> leak can now bypass fill? It seems that we can now
> try to leak a page before fill was seen by host,
> but I did not look into it deeply.
>
> I really like my patch for this better at least for
> current kernel. I agree we need to work more on 2+3.
>

Since we have many customers interested in the "Virtio-balloon 
Enhancement" series,
please review the v17 patches first (it has a dependency on your patch 
for that deadlock fix,
so I included it there too), and we can get back to 2+3 here after that 
series is done. Thanks.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
