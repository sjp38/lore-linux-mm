Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id B41956B0035
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 18:19:09 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f11so2057593yha.14
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 15:19:09 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r49si35271441yho.167.2013.12.27.15.19.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Dec 2013 15:19:08 -0800 (PST)
Message-ID: <52BE0AE6.5000208@oracle.com>
Date: Fri, 27 Dec 2013 18:19:02 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: dump page when hitting a VM_BUG_ON using VM_BUG_ON_PAGE
References: <1388114452-30769-1-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1388114452-30769-1-git-send-email-sasha.levin@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

On 12/26/2013 10:20 PM, Sasha Levin wrote:
> Most of the VM_BUG_ON assertions are performed on a page. Usually, when
> one of these assertions fails we'll get a BUG_ON with a call stack and
> the registers.
>
> I've recently noticed based on the requests to add a small piece of code
> that dumps the page to various VM_BUG_ON sites that the page dump is quite
> useful to people debugging issues in mm.
>
> This patch adds a VM_BUG_ON_PAGE(cond, page) which beyond doing what
> VM_BUG_ON() does, also dumps the page before executing the actual BUG_ON.

Somewhat related to that, I've tried adding a VM_BUG_ON_PAGE in SetPageXXX()
and ClearPageXXX macros to catch cases where page flags are being set or
cleared twice.

There seems to be a lot of those...

Is that a valid use? Or should it be fixed?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
