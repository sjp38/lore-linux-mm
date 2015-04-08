Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 984C96B007B
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 18:20:14 -0400 (EDT)
Received: by pddn5 with SMTP id n5so129811873pdd.2
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 15:20:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pq10si18153412pbb.99.2015.04.08.15.20.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 15:20:13 -0700 (PDT)
Date: Wed, 8 Apr 2015 15:20:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: show free pages per each migrate type
Message-Id: <20150408152011.03d5f94cce0c5ac327bd87c4@linux-foundation.org>
In-Reply-To: <BLU436-SMTP2455A39CB8EF56CED4137DDBAFC0@phx.gbl>
References: <BLU436-SMTP2455A39CB8EF56CED4137DDBAFC0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Neil Zhang <neilzhang1123@hotmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 8 Apr 2015 09:48:06 +0800 Neil Zhang <neilzhang1123@hotmail.com> wrote:

> show detailed free pages per each migrate type in show_free_areas.
> 

It would be good to include example before and after output within the
changelog, so that people can better understand the effect and value of
the proposed change.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
