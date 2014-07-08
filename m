Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 33F306B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 16:19:23 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id l13so714478iga.4
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 13:19:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h20si67981676icc.67.2014.07.08.13.19.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 13:19:22 -0700 (PDT)
Date: Tue, 8 Jul 2014 13:19:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Don't forget to set softdirty on file mapped fault
Message-Id: <20140708131920.2a857d573e8cc89780c9fa1c@linux-foundation.org>
In-Reply-To: <20140708192151.GD17860@moon.sw.swsoft.com>
References: <20140708192151.GD17860@moon.sw.swsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, 8 Jul 2014 23:21:51 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> Otherwise we may not notice that pte was softdirty because pte_mksoft_dirty
> helper _returns_ new pte but not modifies argument.

When fixing a bug, please describe the end-user visible effects of that
bug.

[for the 12,000th time :(]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
