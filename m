Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1759F6B0037
	for <linux-mm@kvack.org>; Tue, 27 May 2014 18:53:56 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id lf12so11507461vcb.29
        for <linux-mm@kvack.org>; Tue, 27 May 2014 15:53:55 -0700 (PDT)
Received: from mail-vc0-x233.google.com (mail-vc0-x233.google.com [2607:f8b0:400c:c03::233])
        by mx.google.com with ESMTPS id wn1si9220365vdc.45.2014.05.27.15.53.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 15:53:55 -0700 (PDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so11547743vcb.10
        for <linux-mm@kvack.org>; Tue, 27 May 2014 15:53:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5384d07e.4504e00a.2680.ffff8c31SMTPIN_ADDED_BROKEN@mx.google.com>
References: <cover.1400607328.git.tony.luck@intel.com>
	<eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
	<20140523033438.GC16945@gchen.bj.intel.com>
	<CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com>
	<20140527161613.GC4108@mcs.anl.gov>
	<5384d07e.4504e00a.2680.ffff8c31SMTPIN_ADDED_BROKEN@mx.google.com>
Date: Tue, 27 May 2014 15:53:55 -0700
Message-ID: <CA+8MBbKuBo4c2v-Y0TOk-LUJuyJsGG=twqQyAPG5WOa8Aj4GyA@mail.gmail.com>
Subject: Re: [PATCH 1/2] memory-failure: Send right signal code to correct thread
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Kamil Iskra <iskra@mcs.anl.gov>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>

>  - make sure that every thread in a recovery aware application should have
>    a SIGBUS handler, inside which
>    * code for SIGBUS(BUS_MCEERR_AR) is enabled for every thread
>    * code for SIGBUS(BUS_MCEERR_AO) is enabled only for a dedicated thread

But how does the kernel know which is the special thread that
should see the "AO" signal?  Broadcasting the signal to all
threads seems to be just as likely to cause problems to
an application as the h/w broadcasting MCE to all processors.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
