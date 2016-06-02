Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C93D6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 06:10:36 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i127so83794903ita.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 03:10:36 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id v23si57406355pfa.20.2016.06.02.03.10.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 03:10:35 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id di3so2939163pab.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 03:10:35 -0700 (PDT)
Date: Thu, 2 Jun 2016 18:10:32 +0800
From: Geliang Tang <geliangtang@gmail.com>
Subject: Re: [PATCH 2/4] mm: kmemleak: remove unused header cpumask.h
Message-ID: <20160602101032.GA10142@OptiPlex>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
 <f0fa3738403f886988141182e8e4bac7efed05c7.1464847139.git.geliangtang@gmail.com>
 <20160602093241.GA24938@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160602093241.GA24938@e104818-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 02, 2016 at 10:32:41AM +0100, Catalin Marinas wrote:
> On Thu, Jun 02, 2016 at 02:15:34PM +0800, Geliang Tang wrote:
> > Remove unused header cpumask.h from mm/kmemleak.c.
> > 
> > Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>

This patch is incorrect because for_each_possible_cpu() is defined in
cpumask.h. Sorry about that.

-Geliang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
