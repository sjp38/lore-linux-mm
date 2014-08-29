Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 21B536B005C
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:18:14 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id et14so7224723pad.2
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:18:13 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id sb10si1525030pac.125.2014.08.29.12.18.13
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 12:18:13 -0700 (PDT)
Message-ID: <5400D1F2.6020900@akamai.com>
Date: Fri, 29 Aug 2014 15:18:10 -0400
From: Jason Baron <jbaron@akamai.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] lib: Use seq_open_private() instead of seq_open()
References: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk> <1409328400-18212-5-git-send-email-rob.jones@codethink.co.uk>
In-Reply-To: <1409328400-18212-5-git-send-email-rob.jones@codethink.co.uk>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Jones <rob.jones@codethink.co.uk>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@codethink.co.uk" <linux-kernel@codethink.co.uk>

On 08/29/2014 12:06 PM, Rob Jones wrote:
> Using seq_open_private() removes boilerplate code from ddebug_proc_open()
>

Looks good.

Acked-by: Jason Baron <jbaron@akamai.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
