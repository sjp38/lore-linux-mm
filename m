Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 259386B5504
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 18:00:32 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id h11so2879283wrs.2
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 15:00:32 -0800 (PST)
Received: from mail.grenz-bonn.de (mail.grenz-bonn.de. [2001:41d0:1:c648::ffe1])
        by mx.google.com with ESMTPS id o6si2792644wmo.12.2018.11.29.15.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 15:00:29 -0800 (PST)
Subject: Re: Question about the laziness of MADV_FREE
References: <47407223-2fa2-2721-c6c3-1c1659dc474e@nh2.me>
 <20181129180057.GZ6923@dhcp22.suse.cz>
 <1423043c-af4b-0288-9f42-e00be320491b@nh2.me>
 <20181129205423.GA6923@dhcp22.suse.cz>
From: =?UTF-8?Q?Niklas_Hamb=c3=bcchen?= <mail@nh2.me>
Message-ID: <42c6c45c-f918-211f-c428-cd45416615df@nh2.me>
Date: Fri, 30 Nov 2018 00:00:26 +0100
MIME-Version: 1.0
In-Reply-To: <20181129205423.GA6923@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On 2018-11-29 21:54, Michal Hocko wrote:
> From a quick look it should be 15*number_of_cpus unless I have missed
> other caching. So this shouldn't be all that much unless you have a
> giant machine with hundreds of cpus.

For clarfication, is that 15*number_of_cpus many pages, or "factor" 15*number_of_cpu off what LazyFree reports?
