Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69B3A6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 18:53:28 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c82so1839237wme.8
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:53:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z74si2010358wmc.120.2017.12.19.15.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 15:53:27 -0800 (PST)
Date: Tue, 19 Dec 2017 15:53:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmots build error: version control conflict marker in file
Message-Id: <20171219155323.7ed0dcfbc89c76eb87aca592@linux-foundation.org>
In-Reply-To: <7cec6594-94c7-a238-4046-0061a9adc20d@infradead.org>
References: <CACT4Y+a0NvG-qpufVcvObd_hWKF9xmTjmjCvV3_13LSgcFXL+Q@mail.gmail.com>
	<20171219090319.GD2787@dhcp22.suse.cz>
	<7cec6594-94c7-a238-4046-0061a9adc20d@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 19 Dec 2017 12:00:12 -0800 Randy Dunlap <rdunlap@infradead.org> wrote:

> 
> Wow. arch/x86/include/asm/processor.h around line 340++ looks like this:
> 
> <<<<<<< HEAD
> struct SYSENTER_stack {
> 	unsigned long		words[64];
> };
> 
> struct SYSENTER_stack_page {
> 	struct SYSENTER_stack stack;
> =======
> struct entry_stack {
> 	unsigned long		words[64];
> };
> 
> struct entry_stack_page {
> 	struct entry_stack stack;
> >>>>>>> linux-next/akpm-base
> } __aligned(PAGE_SIZE);

Yeah, sorry.  Normally I fix those my hand in
linux-next-git-rejects.patch but there were sooooooo many yesterday
that I said screwit.  That all got resolved in today's pull.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
