Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B3EAF6B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 17:28:07 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id a4so87368753wme.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 14:28:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y133si6489786wme.72.2016.02.26.14.28.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 14:28:06 -0800 (PST)
Date: Fri, 26 Feb 2016 14:28:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/7] SLAB support for KASAN
Message-Id: <20160226142804.c247ec724c8cd5c55d86bb3c@linux-foundation.org>
In-Reply-To: <cover.1456504662.git.glider@google.com>
References: <cover.1456504662.git.glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 26 Feb 2016 17:48:40 +0100 Alexander Potapenko <glider@google.com> wrote:

> This patch set implements SLAB support for KASAN

That's a lot of code and I'm not seeing much review activity from
folks.  There was one ack against an earlier version of [4/7] from
Steven Rostedt but that ack wasn't maintained (bad!).

I scanned over these and my plan was to queue them for -next testing
and to await more review/test before proceeding further.  But alas,
there are significant collisions with pending slab patches (all in
linux-next) so could you please take a look at those?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
