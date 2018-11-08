Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8254D6B0674
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 17:23:16 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id j9-v6so19223122pfn.20
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 14:23:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y15si4699687pgf.321.2018.11.08.14.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 14:23:15 -0800 (PST)
Date: Thu, 8 Nov 2018 14:23:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] z3fold: fix wrong handling of headless pages
Message-Id: <20181108142312.f5efdc72ca0d64dc80046c92@linux-foundation.org>
In-Reply-To: <20181108134540.12756-1-ks77sj@gmail.com>
References: <CAMJBoFP3C5NffHf2bPaY-W2qXPLs6z+Ker+Z+Sq_3MHV5xekHQ@mail.gmail.com>
	<20181108134540.12756-1-ks77sj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jongseok Kim <ks77sj@gmail.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  8 Nov 2018 22:45:40 +0900 Jongseok Kim <ks77sj@gmail.com> wrote:

> Yes, you are right.
> I think that's the best way to deal it.
> Thank you.


I did this:

Link: http://lkml.kernel.org/r/20181105162225.74e8837d03583a9b707cf559@gmail.com
Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
Signed-off-by: Jongseok Kim <ks77sj@gmail.com>
Reported-by-by: Jongseok Kim <ks77sj@gmail.com>
Reviewed-by: Snild Dolkow <snild@sony.com>
