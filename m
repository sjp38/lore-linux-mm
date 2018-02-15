Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F66F6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 18:17:20 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id 62so1647822iow.16
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 15:17:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b2sor6702841itg.52.2018.02.15.15.17.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 15:17:19 -0800 (PST)
Date: Thu, 15 Feb 2018 17:17:14 -0600
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [PATCH 3/3] percpu: allow select gfp to be passed to underlying
 allocators
Message-ID: <20180215231714.GB79973@localhost>
References: <cover.1518668149.git.dennisszhou@gmail.com>
 <a166972c727e3a1235a7ad17b9df94ca407a1548.1518668149.git.dennisszhou@gmail.com>
 <20180215214148.GV695913@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215214148.GV695913@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Daniel Borkmann <daniel@iogearbox.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Thu, Feb 15, 2018 at 01:41:48PM -0800, Tejun Heo wrote:
> On Thu, Feb 15, 2018 at 10:08:16AM -0600, Dennis Zhou wrote:
> > +/* the whitelisted flags that can be passed to the backing allocators */
> > +#define gfp_percpu_mask(gfp) (((gfp) & (__GFP_NORETRY | __GFP_NOWARN)) | \
> > +			      GFP_KERNEL)
> 
> Isn't there just one place where gfp comes in from outside?  If so,
> this looks like a bit of overkill.  Can't we just filter there?
> 

I agree, but it's also nice having a single place where flags can be
added or removed. The primary motivator was for the "| GFP_KERNEL", but
as suggested in the other patch this is getting removed. I guess I still
lean towards having it as it's explicit and helps gate both the balance
path and the user allocation path.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
