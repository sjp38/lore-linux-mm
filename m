Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 787376B0254
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 15:23:12 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id n186so1724225wmn.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 12:23:12 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o63si340284wmb.95.2016.03.09.12.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 12:23:11 -0800 (PST)
Date: Wed, 9 Mar 2016 12:23:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 0/7] SLAB support for KASAN
Message-Id: <20160309122306.6bf0562071d06cf16bd916f4@linux-foundation.org>
In-Reply-To: <cover.1457519440.git.glider@google.com>
References: <cover.1457519440.git.glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed,  9 Mar 2016 12:10:13 +0100 Alexander Potapenko <glider@google.com> wrote:

> This patch set implements SLAB support for KASAN

I'll queue all this up for some testing.  I'm undecided about feeding
it into 4.5 - it is very late.  I'll be interested in advice from
others on this...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
