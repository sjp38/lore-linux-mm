Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 144FF6B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 04:06:48 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id mc6so5630047lab.34
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 01:06:48 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id i11si2169528lbg.92.2014.08.19.01.06.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Aug 2014 01:06:47 -0700 (PDT)
From: Marc Dietrich <marvin24@gmx.de>
Subject: Re: [PATCH v2 3/4] zram: zram memory size limitation
Date: Tue, 19 Aug 2014 10:06:22 +0200
Message-ID: <7959928.Exbvf4HrNB@fb07-iapwap2>
In-Reply-To: <1408434887-16387-4-git-send-email-minchan@kernel.org>
References: <1408434887-16387-1-git-send-email-minchan@kernel.org> <1408434887-16387-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, ds2horner@gmail.com

Am Dienstag, 19. August 2014, 16:54:46 schrieb Minchan Kim:
> Since zram has no control feature to limit memory usage,
> it makes hard to manage system memrory.
> 
> This patch adds new knob "mem_limit" via sysfs to set up the
> a limit so that zram could fail allocation once it reaches
> the limit.

Sorry to jump in late with a probably silly question, but I couldn't find the 
answer easily. What's the difference between disksize and mem_limit?
I assume the former is uncompressed size (virtual size) and the latter is 
compressed size (real memory usage)? Maybe the difference should be made 
clearer in the documentation.
If disksize is the uncompressed size, why would we want to set this at all?

Marc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
