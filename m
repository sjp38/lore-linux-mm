Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75F5B6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 05:32:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g64so46109792pfb.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 02:32:46 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id fk7si18952296pab.97.2016.06.02.02.32.45
        for <linux-mm@kvack.org>;
        Thu, 02 Jun 2016 02:32:45 -0700 (PDT)
Date: Thu, 2 Jun 2016 10:32:41 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 2/4] mm: kmemleak: remove unused header cpumask.h
Message-ID: <20160602093241.GA24938@e104818-lin.cambridge.arm.com>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
 <f0fa3738403f886988141182e8e4bac7efed05c7.1464847139.git.geliangtang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f0fa3738403f886988141182e8e4bac7efed05c7.1464847139.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 02, 2016 at 02:15:34PM +0800, Geliang Tang wrote:
> Remove unused header cpumask.h from mm/kmemleak.c.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
