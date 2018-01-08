Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD836B0260
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 14:43:35 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u16so8373523pfh.7
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 11:43:35 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTPS id f1si8994407plb.751.2018.01.08.11.43.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 11:43:34 -0800 (PST)
Subject: Re: [PATCH 8/8] net: tipc: remove unused hardirq.h
References: <1510959741-31109-8-git-send-email-yang.s@alibaba-inc.com>
 <4ed1efbc-5fb8-7412-4f46-1e3a91a98373@windriver.com>
 <b48afbb6-771f-84b1-8329-d5941eff086b@alibaba-inc.com>
 <20180105.101706.344316131945042174.davem@davemloft.net>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <6b987b67-ea1a-fa43-ae8d-d70b8801c2f7@alibaba-inc.com>
Date: Tue, 09 Jan 2018 03:43:14 +0800
MIME-Version: 1.0
In-Reply-To: <20180105.101706.344316131945042174.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, ying.xue@windriver.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, jon.maloy@ericsson.com



On 1/5/18 7:17 AM, David Miller wrote:
> From: "Yang Shi" <yang.s@alibaba-inc.com>
> Date: Fri, 05 Jan 2018 06:46:48 +0800
> 
>> Any more comment on this change?
> 
> These patches were not really submitted properly.
> 
> If you post a series, the series goes to one destination and
> one tree.
> 
> If they are supposed to go to multiple trees, submit them
> individually rather than as a series.  With clear indications
> in the Subject lines which tree should be taking the patch.

Thanks for the comment. I will resend the net patches in a separate 
series to you.

Yang

> 
> Thank you.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
