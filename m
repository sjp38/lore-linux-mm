Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 384D36B02F3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:07:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v102so25928201wrb.2
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 13:07:35 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u91si9531431wrc.328.2017.07.24.13.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 13:07:34 -0700 (PDT)
Date: Mon, 24 Jul 2017 16:07:20 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: Re: [PATCH 07/10] percpu: fix misnomer in schunk/dchunk variable
 names
Message-ID: <20170724200719.GB91613@dennisz-mbp.dhcp.thefacebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-8-dennisz@fb.com>
 <20170717191009.GA585283@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170717191009.GA585283@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

Hi Tejun,

On Mon, Jul 17, 2017 at 03:10:09PM -0400, Tejun Heo wrote:

> >  	/*
> > +	 * Initialize first chunk.
> > +	 * pcpu_first_chunk will always manage the dynamic region of the
> > +	 * first chunk.  The static region is dropped as those addresses
> 
> Would "not covered by any chunk" be clearer than "dropped"?

I've updated the comments in the new revision. This is explained in the
function comment now.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
