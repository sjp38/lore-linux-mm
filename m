Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA2CD6B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 21:15:25 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g22-v6so8852871ioh.5
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 18:15:25 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n12-v6si236148itb.24.2018.06.07.18.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Jun 2018 18:15:24 -0700 (PDT)
Subject: Re: mmotm 2018-06-07-16-59 uploaded (scsi/ipr)
References: <20180607235947.xWQtg%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <656ccc09-951c-4b74-05a0-bc6f510a6453@infradead.org>
Date: Thu, 7 Jun 2018 18:15:19 -0700
MIME-Version: 1.0
In-Reply-To: <20180607235947.xWQtg%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

On 06/07/2018 04:59 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2018-06-07-16-59 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 

on i386 (randconfig):

../drivers/scsi/ipr.c: In function 'ipr_mask_and_clear_interrupts':
../drivers/scsi/ipr.c:767:3: error: implicit declaration of function 'writeq_relaxed' [-Werror=implicit-function-declaration]
   writeq_relaxed(~0, ioa_cfg->regs.set_interrupt_mask_reg);
   ^



need config?
-- 
~Randy
