Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B52886B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 05:45:27 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id g184so54923548oif.6
        for <linux-mm@kvack.org>; Wed, 03 May 2017 02:45:27 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id k58si8273934otd.102.2017.05.03.02.45.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 May 2017 02:45:26 -0700 (PDT)
Subject: Re: RFC: post-init-read-only protection for data allocated
 dynamically
References: <3eba3df7-6694-5c47-48f4-30088845035b@huawei.com>
 <20170428074540.GB9399@dhcp22.suse.cz>
 <20170502164748.GA19165@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <f18c2c02-e1ee-385c-31b5-ad91ec33bce2@huawei.com>
Date: Wed, 3 May 2017 12:44:22 +0300
MIME-Version: 1.0
In-Reply-To: <20170502164748.GA19165@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org



On 02/05/17 19:47, Michal Hocko wrote:
> [You have already started new thread with the way how to introduce a new
> zone and that might turn out to be useful but I think it is much more
> important to understand requirements for the usecase you have in mind as
> first]

Ok, I'm sorry this was not clear, I'll detail it more.

---
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
