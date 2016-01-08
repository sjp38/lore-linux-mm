Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E8E72828ED
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:38:25 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id uo6so271799758pac.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:38:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k62si8046809pfb.74.2016.01.08.15.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 15:38:25 -0800 (PST)
Date: Fri, 8 Jan 2016 15:38:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: do some cleanup
Message-Id: <20160108153824.076a81042fa3752d6012466e@linux-foundation.org>
In-Reply-To: <20160108141459.5da3b29c@debian>
References: <20160108141459.5da3b29c@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 8 Jan 2016 14:14:59 +0800 Wang Xiaoqiang <wangxq10@lzu.edu.cn> wrote:

> removed extra newlines and avoid too many characters in one line.

Some of these patches are just too trivial, sorry.

And that doesn't mean "send them to trivial@kernel.org"!  They're too
trivial for that as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
