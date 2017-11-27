Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15C466B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:41:09 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id 78so18734026qkz.13
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:41:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o71sor1972790qka.48.2017.11.27.11.41.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 11:41:08 -0800 (PST)
Date: Mon, 27 Nov 2017 11:41:05 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info (crisv32 hang)
Message-ID: <20171127194105.GM983427@devbig577.frc2.facebook.com>
References: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr>
 <20171118182542.GA23928@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171118182542.GA23928@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com

Hello,

I'm reverting the offending commit till we figure out what's going on.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
