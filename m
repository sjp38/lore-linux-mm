Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 830D26B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:33:39 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id j202so18840089qke.2
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:33:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f94sor19463386qki.19.2017.11.27.12.33.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 12:33:38 -0800 (PST)
Date: Mon, 27 Nov 2017 12:33:35 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info (crisv32 hang)
Message-ID: <20171127203335.GQ983427@devbig577.frc2.facebook.com>
References: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr>
 <20171118182542.GA23928@roeck-us.net>
 <20171127194105.GM983427@devbig577.frc2.facebook.com>
 <nycvar.YSQ.7.76.1711271515540.5925@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1711271515540.5925@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Guenter Roeck <linux@roeck-us.net>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com

Hello,

On Mon, Nov 27, 2017 at 03:31:52PM -0500, Nicolas Pitre wrote:
> So IMHO I don't think reverting the commit is the right thing to do. 
> That commit is clearly not at fault here.

It's not about the blame.  We just want to avoid breaking boot in a
way which is difficult to debug.  Once cris is fixed, we can re-apply
the patch.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
