Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5686B026F
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 10:05:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i10-v6so5776570eds.19
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 07:05:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8-v6si3176649edb.188.2018.07.02.07.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 07:05:05 -0700 (PDT)
Date: Mon, 2 Jul 2018 16:05:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180702140502.GZ19043@dhcp22.suse.cz>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
 <20180629183501.9e30c26135f11853245c56c7@linux-foundation.org>
 <084aeccb-2c54-2299-8bf0-29a10cc0186e@linux.alibaba.com>
 <20180629201547.5322cfc4b52d19a0443daec2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180629201547.5322cfc4b52d19a0443daec2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Fri 29-06-18 20:15:47, Andrew Morton wrote:
[...]
> Would one of your earlier designs have addressed all usecases?  I
> expect the dumb unmap-a-little-bit-at-a-time approach would have?

It has been already pointed out that this will not work. You simply
cannot drop the mmap_sem during unmap because another thread could
change the address space under your feet. So you need some form of
VM_DEAD and handle concurrent and conflicting address space operations.
-- 
Michal Hocko
SUSE Labs
