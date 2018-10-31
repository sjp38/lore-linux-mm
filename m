Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C865B6B02E7
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:11:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z72-v6so1197528ede.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:11:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j19-v6si13520502edq.39.2018.10.31.06.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 06:11:40 -0700 (PDT)
Subject: Re: [PATCH] memory_hotplug: cond_resched in __remove_pages
References: <20181031125840.23982-1-mhocko@kernel.org>
From: Johannes Thumshirn <jthumshirn@suse.de>
Message-ID: <d7c6d912-50fc-19f9-eda3-19837ae5d332@suse.de>
Date: Wed, 31 Oct 2018 14:11:39 +0100
MIME-Version: 1.0
In-Reply-To: <20181031125840.23982-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Thumshirn <jthumshirn@suse.de>

-- 
Johannes Thumshirn                                        SUSE Labs
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 NA 1/4 rnberg
GF: Felix ImendA?rffer, Jane Smithard, Graham Norton
HRB 21284 (AG NA 1/4 rnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
