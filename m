Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id D4E956B0257
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 20:46:02 -0500 (EST)
Received: by qgeb1 with SMTP id b1so104650891qge.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 17:46:02 -0800 (PST)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id r66si15443419qkl.103.2015.12.04.17.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 17:46:02 -0800 (PST)
Received: by qgeb1 with SMTP id b1so104650697qge.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 17:46:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151204170113.c5cd8a9cc9658c491851bc33@linux-foundation.org>
References: <201512050045.l2G9WhTi%fengguang.wu@intel.com>
	<20151204151424.e73641da44c61f20f10d93e9@linux-foundation.org>
	<20151204151913.166e5cb795359ff1a53d26ac@linux-foundation.org>
	<CAJQetW4L6Zuzd9GENK6XMg+OVtFUjyE4jOzoG+VB3HtwmoUmiA@mail.gmail.com>
	<20151204170113.c5cd8a9cc9658c491851bc33@linux-foundation.org>
Date: Fri, 4 Dec 2015 17:46:01 -0800
Message-ID: <CAJQetW54FNRKd5LtpkAk0P_bPyAZi6iKnZhEhz1n9oSOm-Wc9Q@mail.gmail.com>
Subject: Re: [linux-next:master 4174/4356] kernel/built-in.o:undefined
 reference to `mmap_rnd_bits'
From: Daniel Cashman <dcashman@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Mark Brown <broonie@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, dcashman@android.com

> > I've left the question of whether or not
> > the value should be the number of randomized bits (current situation)
> > or the size of the address space chunk affected up to akpm@.
>
> Does it matter much?  It can always be changed later if it proves to be
> a problem.

Motivation for the suggestions was to get rid of the page size
consideration in setting default min/max Kconfig values to reduce line
count, otherwise both options are about equivalent.

> > Please let me know what else should be done in v6 to keep these in.
>
> It sounds like all we need to do at present is to fix this build error?

My apologies, I thought this was the one related to CONFIG_MMU=n.
I've reproduced locally and will look into this on Monday.

Thank You,
Dan

On Fri, Dec 4, 2015 at 5:01 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 4 Dec 2015 16:56:19 -0800 Daniel Cashman <dcashman@google.com> wrote:
>
>> I've left the question of whether or not
>> the value should be the number of randomized bits (current situation)
>> or the size of the address space chunk affected up to akpm@.
>
> Does it matter much?  It can always be changed later if it proves to be
> a problem.
>
>> Please let me know what else should be done in v6 to keep these in.
>
> It sounds like all we need to do at present is to fix this build error?



-- 
Dan Cashman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
