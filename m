Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 59874828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:44:49 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id z14so160468264igp.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 12:44:49 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0046.hostedemail.com. [216.40.44.46])
        by mx.google.com with ESMTPS id p123si7277311ioe.111.2016.01.13.12.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 12:44:48 -0800 (PST)
Date: Wed, 13 Jan 2016 15:44:45 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 7/7] sparc64: mm/gup: add gup trace points
Message-ID: <20160113154445.266b0249@gandalf.local.home>
In-Reply-To: <20160113.152138.454507206353287548.davem@davemloft.net>
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
	<1449696151-4195-8-git-send-email-yang.shi@linaro.org>
	<569693B4.6060305@linaro.org>
	<20160113.152138.454507206353287548.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: yang.shi@linaro.org, akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, sparclinux@vger.kernel.org

On Wed, 13 Jan 2016 15:21:38 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: "Shi, Yang" <yang.shi@linaro.org>
> Date: Wed, 13 Jan 2016 10:13:08 -0800
> 
> > Any comment on this one? The tracing part review has been done.  
> 
> I thought this was going to simply be submitted upstream via
> another tree.
> 
> If you just want my ack then:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Yep, that's what I wanted. Thanks!

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
