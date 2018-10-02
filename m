Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 174056B027A
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:04:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 31-v6so62533edr.19
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:04:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c8-v6si5858829edc.311.2018.10.02.08.04.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 08:04:04 -0700 (PDT)
Subject: Re: [PATCH] mm:slab: Adjust the print format for the slabinfo
References: <20181002025939.115804-1-hangdianqj@163.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ad1bbce1-bca9-ff8e-c2c5-7ab672203dd9@suse.cz>
Date: Tue, 2 Oct 2018 17:04:02 +0200
MIME-Version: 1.0
In-Reply-To: <20181002025939.115804-1-hangdianqj@163.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jun qian <hangdianqj@163.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Barry song <21cnbao@gmail.com>

On 10/2/18 4:59 AM, jun qian wrote:
> Header and the corresponding information is not aligned,
> adjust the printing format helps us to understand the slabinfo better.
> 
> Signed-off-by: jun qian <hangdianqj@163.com>
> Cc: Barry song <21cnbao@gmail.com>

I've tried the patch and it makes the slabinfo not fit my screen
anymore, and the value density is very sparse. IMHO the current layout
is better, sorry.

Vlastimil
