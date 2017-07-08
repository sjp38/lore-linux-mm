Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8AE440843
	for <linux-mm@kvack.org>; Sat,  8 Jul 2017 16:33:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u62so71404559pgb.13
        for <linux-mm@kvack.org>; Sat, 08 Jul 2017 13:33:48 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a186si4878624pfb.402.2017.07.08.13.33.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Jul 2017 13:33:47 -0700 (PDT)
Date: Sat, 8 Jul 2017 16:33:15 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: Re: [PATCH 3/4] percpu: expose statistics about percpu memory via
 debugfs
Message-ID: <20170708203314.GA16910@dennisz-mbp>
References: <20170619232832.27116-1-dennisz@fb.com>
 <20170619232832.27116-4-dennisz@fb.com>
 <CAMuHMdWXR7tN01PArsSA5nwZV1GF=YgNdZuSeNq_ri1GoYSKCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAMuHMdWXR7tN01PArsSA5nwZV1GF=YgNdZuSeNq_ri1GoYSKCQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Fri, Jul 07, 2017 at 10:16:01AM +0200, Geert Uytterhoeven wrote:
> Hi Dennis,
> 
> On Tue, Jun 20, 2017 at 1:28 AM, Dennis Zhou <dennisz@fb.com> wrote:
> 
> Just wondering: does this option make sense to enable on !SMP?
> 
> If not, you may want to make it depend on SMP.
> 
> Thanks!
> 
> Gr{oetje,eeting}s,
> 
>                         Geert

Hi Geert,

The percpu allocator is still used on UP configs, so it would still
provide useful data.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
