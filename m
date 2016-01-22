Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id C4EA46B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 02:13:10 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id g73so81429692ioe.3
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 23:13:10 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id 14si10169602ioi.168.2016.01.21.23.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 23:13:10 -0800 (PST)
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 301D020DCC
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 02:13:03 -0500 (EST)
Subject: Re: [PATCH, REGRESSION v3] mm: make apply_to_page_range more robust
References: <56A06EC7.9060106@nextfour.com>
 <alpine.DEB.2.10.1601211511230.9813@chino.kir.corp.google.com>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <56A1D67C.9080301@iki.fi>
Date: Fri, 22 Jan 2016 09:13:00 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1601211511230.9813@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

On 01/22/2016 01:12 AM, David Rientjes wrote:
> NACK to your patch as it is just covering up buggy code silently. The 
> problem needs to be addressed in change_memory_common() to return if 
> there is no size to change (numpages == 0). It's a two line fix to 
> that function. 

So add a WARN_ON there to *warn* about the situations. There's really no 
need to BUG_ON here.

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
