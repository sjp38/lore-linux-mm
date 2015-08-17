Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DEE346B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:28:15 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so116446681pab.0
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 14:28:15 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id o2si23363073pdg.24.2015.08.17.14.28.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 14:28:15 -0700 (PDT)
Received: by pawq9 with SMTP id q9so18842150paw.3
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 14:28:14 -0700 (PDT)
Date: Mon, 17 Aug 2015 14:28:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
In-Reply-To: <alpine.DEB.2.10.1508121327290.5382@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1508171427560.23237@chino.kir.corp.google.com>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp> <1439365520-12605-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1439365520-12605-2-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.DEB.2.10.1508121327290.5382@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, 12 Aug 2015, David Rientjes wrote:

> I'm happy with this and thanks very much for going the extra mile and 
> breaking the usage down by hstate size.
> 
> I'd be interested in the comments of others, though, to see if there is 
> any reservation about the hstate size breakdown.  It may actually find no 
> current customer who is interested in parsing it.  (If we keep it, I would 
> suggest the 'x' change to '*' similar to per-order breakdowns in 
> show_mem()).  It may also be possible to add it later if a definitive 
> usecase is presented.
> 
> But overall I'm very happy with the new addition and think it's a good 
> solution to the problem.
> 

No objections from anybody else, so

Acked-by: David Rientjes <rientjes@google.com>

Thanks Naoya!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
