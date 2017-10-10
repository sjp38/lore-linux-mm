Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE7566B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 15:37:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y142so5445wme.12
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 12:37:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 128si10146503wmr.119.2017.10.10.12.37.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 12:37:52 -0700 (PDT)
Date: Tue, 10 Oct 2017 12:37:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2016-08-02-15-53 uploaded
Message-Id: <20171010123749.2c59f3b762b3c0b33e80a67d@linux-foundation.org>
In-Reply-To: <CAGF4SLgi6jgtxbqtTEjL8FGXUHHsSm6KeoVqANLt3LB6OTBboA@mail.gmail.com>
References: <57a124aa.eJmVCvd1SOHlQ1X8%akpm@linux-foundation.org>
	<CAGF4SLgi6jgtxbqtTEjL8FGXUHHsSm6KeoVqANLt3LB6OTBboA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Mayatskih <v.mayatskih@gmail.com>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org, ocfs2-devel@oss.oracle.com, piaojun <piaojun@huawei.com>, Joseph Qi <joseph.qi@huawei.com>, Jiufei Xue <xuejiufei@huawei.com>, Mark Fasheh <mfasheh@suse.de>, Joel Becker <jlbec@evilplan.org>, Junxiao Bi <junxiao.bi@oracle.com>

On Tue, 10 Oct 2017 14:06:41 -0400 Vitaly Mayatskih <v.mayatskih@gmail.com> wrote:

> * ocfs2-dlm-continue-to-purge-recovery-lockres-when-recovery
> -master-goes-down.patch
> 
> This one completely broke two node cluster use case: when one node dies,
> the other one either eventually crashes (~4.14-rc4) or locks up (pre-4.14).

Are you sure?

Are you able to confirm that reverting this patch (ee8f7fcbe638b07e8)
and only this patch fixes up current mainline kernels?

Are you able to supply more info on the crashes and lockups so that the
ocfs2 developers can understand the failures?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
