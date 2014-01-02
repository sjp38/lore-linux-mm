Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A6DE36B003A
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 17:13:48 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so14535708pde.41
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 14:13:48 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id nu5si43719046pbc.28.2014.01.02.14.13.46
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 14:13:47 -0800 (PST)
Message-ID: <52C5E493.6090007@sr71.net>
Date: Thu, 02 Jan 2014 14:13:39 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCHv3 06/11] arm: use is_vmalloc_addr
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org> <1388699609-18214-7-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1388699609-18214-7-git-send-email-lauraa@codeaurora.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On 01/02/2014 01:53 PM, Laura Abbott wrote:
> is_vmalloc_addr already does the range checking against VMALLOC_START and
> VMALLOC_END. Use it.

FWIW, these first 6 look completely sane and should get merged
regardless of what gets done with the rest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
