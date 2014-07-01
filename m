Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id D71E56B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 22:15:25 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so6652496wib.3
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 19:15:25 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id o2si26109943wje.108.2014.06.30.19.15.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 19:15:24 -0700 (PDT)
Date: Tue, 1 Jul 2014 04:15:23 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] hwpoison: Fix race with changing page during offlining
 v2
Message-ID: <20140701021523.GK5714@two.firstfloor.org>
References: <1404174736-17480-1-git-send-email-andi@firstfloor.org>
 <20140701012146.GA23311@nhori.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140701012146.GA23311@nhori.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andi Kleen <ak@linux.intel.com>

> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Is it -stable matter?
> Maybe 2.6.38+ can profit from this.

Probably not, it's not a critical bug fix.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
