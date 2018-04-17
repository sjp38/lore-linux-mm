Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 985276B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 19:55:12 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id c11-v6so13295551pll.13
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 16:55:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j61-v6si15698034plb.317.2018.04.17.16.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 16:55:11 -0700 (PDT)
Date: Tue, 17 Apr 2018 16:55:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc: remove realsize in free_area_init_core()
Message-Id: <20180417165510.a3da1849194d4b7bbb60fdec@linux-foundation.org>
In-Reply-To: <20180413083859.65888-1-richard.weiyang@gmail.com>
References: <20180413083859.65888-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, linux-mm@kvack.org

On Fri, 13 Apr 2018 16:38:59 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> Highmem's realsize always equals to freesize, so it is not necessary to
> spare a variable to record this.

Agreed.  The code seems a bit more fragile after this alteration, but I
guess the onus is on us, as always, to not screw it up later on.  hm..
