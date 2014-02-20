Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 55A466B005A
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 00:41:45 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id rl12so976484iec.15
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 21:41:45 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id m10si3292935icu.7.2014.02.19.21.41.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Feb 2014 21:41:40 -0800 (PST)
Message-ID: <53059590.7040506@infradead.org>
Date: Wed, 19 Feb 2014 21:41:36 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: mmotm 2014-02-19-16-07 uploaded (sound/soc/intel/sst-dsp.c)
References: <20140220000827.17F275A42DC@corp2gmr1-2.hot.corp.google.com>
In-Reply-To: <20140220000827.17F275A42DC@corp2gmr1-2.hot.corp.google.com>
Content-Type: text/plain; charset=windows-1256
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Liam Girdwood <lgirdwood@gmail.com>

On 02/19/14 16:08, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2014-02-19-16-07 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 

on i386:
(from linux-next)

  CC      sound/soc/intel/sst-dsp.o
sound/soc/intel/sst-dsp.c: In function 'sst_dsp_outbox_write':
sound/soc/intel/sst-dsp.c:218:2: error: implicit declaration of function 'memcpy_toio' [-Werror=implicit-function-declaration]
sound/soc/intel/sst-dsp.c: In function 'sst_dsp_outbox_read':
sound/soc/intel/sst-dsp.c:231:2: error: implicit declaration of function 'memcpy_fromio' [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors
make[4]: *** [sound/soc/intel/sst-dsp.o] Error 1


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
