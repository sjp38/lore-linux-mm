Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83A1B6B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:59:11 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id y38so68041968qta.6
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:59:11 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id 17si6166388qki.114.2016.10.13.17.59.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 17:59:10 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
 <20161013233139.GE32534@mtj.duckdns.org>
 <b1b3d53c-b6d9-f888-e123-1b6afe9b2e98@zoho.com>
 <20161014002843.GH32534@mtj.duckdns.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <330464cd-a7d4-f1e1-da93-a6fd172ee561@zoho.com>
Date: Fri, 14 Oct 2016 08:58:53 +0800
MIME-Version: 1.0
In-Reply-To: <20161014002843.GH32534@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/10/14 8:28, Tejun Heo wrote:
> Hello,
> 
> On Fri, Oct 14, 2016 at 08:23:06AM +0800, zijun_hu wrote:
>> for the current code, only power of 2 alignment value can works well
>>
>> is it acceptable to performing a power of 2 checking and returning error code
>> if fail?
> 
> Yeah, just add is_power_of_2() test to the existing sanity check.
> 
> Thanks.
> 
okay. i will do that

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
