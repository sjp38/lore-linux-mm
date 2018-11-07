Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2F66B04BB
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 01:19:46 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id e97-v6so15277242plb.10
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 22:19:46 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id d124-v6si50874756pfc.249.2018.11.06.22.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 22:19:45 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 07 Nov 2018 11:49:44 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v1 0/4]mm: convert totalram_pages, totalhigh_pages and
 managed pages to atomic
In-Reply-To: <20181106162206.0f43c1eb16c3dd812bdadbdd@linux-foundation.org>
References: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
 <20181106162206.0f43c1eb16c3dd812bdadbdd@linux-foundation.org>
Message-ID: <33a9d26369468824e27de5a636e4e843@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018-11-07 05:52, Andrew Morton wrote:
> On Fri, 26 Oct 2018 16:30:58 +0530 Arun KS <arunks@codeaurora.org> 
> wrote:
> 
>> This series convert totalram_pages, totalhigh_pages and
>> zone->managed_pages to atomic variables.
> 
> The whole point appears to be removal of managed_page_count_lock, yes?
> 
> Why?  What is the value of this patchset?  If "performance" then are 
> any
> measurements available?

Hello Andrew,

https://patchwork.kernel.org/patch/10670787/
In version 2, I have added motivation behind this conversion. Pasting 
same here,

totalram_pages, zone->managed_pages and totalhigh_pages updates are 
protected by managed_page_count_lock, but readers never care about it. 
Convert these variables to atomic to avoid readers potentially seeing a 
store tear. I don't think we have a performance improvement here.

Regards,
Arun
