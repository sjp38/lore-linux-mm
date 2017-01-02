Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65AA16B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 03:47:35 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id j10so106564197wjb.3
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 00:47:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ri10si40770098wjb.215.2017.01.02.00.47.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 00:47:34 -0800 (PST)
Date: Mon, 2 Jan 2017 09:47:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: cma: print allocation failure reason and bitmap
 status
Message-ID: <20170102084730.GA18048@dhcp22.suse.cz>
References: <CGME20161229022722epcas5p4be0e1924f3c8d906cbfb461cab8f0374@epcas5p4.samsung.com>
 <1482978482-14007-1-git-send-email-jaewon31.kim@samsung.com>
 <20161229091449.GG29208@dhcp22.suse.cz>
 <xa1th95m7r6w.fsf@mina86.com>
 <58660BBE.1040807@samsung.com>
 <20161230094411.GD13301@dhcp22.suse.cz>
 <xa1tpok6igqb.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xa1tpok6igqb.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, m.szyprowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Sun 01-01-17 22:59:40, Michal Nazarewicz wrote:
[...]
> Actually, Linux style is more like:
> 
> #ifdef CONFIG_CMA_DEBUG
> static void cma_debug_show_areas()
> {
> 	a?|
> }
> #else
> static inline void cma_debug_show_areas() { }
> #endif

yes, we usually do that when the function is externally visible. Inline
ifdef for static functions saves few lines. Not that it would matter
much though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
