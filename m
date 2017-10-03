Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D7A756B0253
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 18:36:46 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id m123so1440384ita.4
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 15:36:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h73sor5978308ith.72.2017.10.03.15.36.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 15:36:45 -0700 (PDT)
Date: Tue, 3 Oct 2017 15:36:42 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info
Message-ID: <20171003223642.GN3301751@devbig577.frc2.facebook.com>
References: <nycvar.YSQ.7.76.1710031638450.5407@knanqh.ubzr>
 <20171003210540.GM3301751@devbig577.frc2.facebook.com>
 <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Tue, Oct 03, 2017 at 06:29:49PM -0400, Nicolas Pitre wrote:
> I'm not sure i understand that code fully, but maybe the following patch 
> could be a better fit:
> 
> ----- >8
> Subject: [PATCH] percpu: don't forget to free the temporary struct pcpu_alloc_info

So, IIRC, the error path is either boot fail or some serious bug in
arch code.  It really doesn't matter whether we free a page or not.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
