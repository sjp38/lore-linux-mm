Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5DE6B0259
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 20:01:16 -0500 (EST)
Received: by wmec201 with SMTP id c201so96915305wme.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 17:01:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wk7si21953167wjb.244.2015.12.04.17.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 17:01:15 -0800 (PST)
Date: Fri, 4 Dec 2015 17:01:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 4174/4356] kernel/built-in.o:undefined
 reference to `mmap_rnd_bits'
Message-Id: <20151204170113.c5cd8a9cc9658c491851bc33@linux-foundation.org>
In-Reply-To: <CAJQetW4L6Zuzd9GENK6XMg+OVtFUjyE4jOzoG+VB3HtwmoUmiA@mail.gmail.com>
References: <201512050045.l2G9WhTi%fengguang.wu@intel.com>
	<20151204151424.e73641da44c61f20f10d93e9@linux-foundation.org>
	<20151204151913.166e5cb795359ff1a53d26ac@linux-foundation.org>
	<CAJQetW4L6Zuzd9GENK6XMg+OVtFUjyE4jOzoG+VB3HtwmoUmiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@google.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Mark Brown <broonie@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 4 Dec 2015 16:56:19 -0800 Daniel Cashman <dcashman@google.com> wrote:

> I've left the question of whether or not
> the value should be the number of randomized bits (current situation)
> or the size of the address space chunk affected up to akpm@.

Does it matter much?  It can always be changed later if it proves to be
a problem.

> Please let me know what else should be done in v6 to keep these in.

It sounds like all we need to do at present is to fix this build error?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
