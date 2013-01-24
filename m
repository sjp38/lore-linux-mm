Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id B30646B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 12:16:36 -0500 (EST)
Received: by mail-oa0-f51.google.com with SMTP id n12so10169645oag.38
        for <linux-mm@kvack.org>; Thu, 24 Jan 2013 09:16:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130124055042.GE22654@blaptop>
References: <1358848018-3679-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<20130123042714.GD2723@blaptop>
	<CALF0-+V6D1Ka9SNyrgRAgTSGLUTp_9y4vYwauSx1qCfU-JOwjA@mail.gmail.com>
	<20130124055042.GE22654@blaptop>
Date: Thu, 24 Jan 2013 14:16:35 -0300
Message-ID: <CALF0-+VRF=ZK7YH8AkrFM2T4QQ4xz8-MdceSHr4biALxZfGdzA@mail.gmail.com>
Subject: Re: [RFC/PATCH] scripts/tracing: Add trace_analyze.py tool
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, Pekka Enberg <penberg@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Ingo Molnar <mingo@redhat.com>

On Thu, Jan 24, 2013 at 2:50 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Wed, Jan 23, 2013 at 06:37:56PM -0300, Ezequiel Garcia wrote:
>
>>
>> > 2. Does it support alloc_pages family?
>> >    kmem event trace already supports it. If it supports, maybe we can replace
>> >    CONFIG_PAGE_OWNER hack.
>> >
>>
>> Mmm.. no, it doesn't support alloc_pages and friends, for we found
>> no reason to do it.
>> However, it sounds like a nice idea, on a first thought.
>>
>> I'll review CONFIG_PAGE_OWNER patches and see if I can come up with something.
>
> Thanks!
>

I'm searching CONFIG_PAGE_OWNER patches, but I could only find this one
for v2.6.13:

http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.13-rc3/2.6.13-rc3-mm1/broken-out/page-owner-tracking-leak-detector.patch

Is there a more recent one?

-- 
    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
