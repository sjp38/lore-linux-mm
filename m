Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id EE2596B0253
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 17:13:36 -0400 (EDT)
Received: by paccq16 with SMTP id cq16so1411627pac.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 14:13:36 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id ml5si5488183pab.172.2015.08.13.14.13.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 14:13:36 -0700 (PDT)
Received: by pdrh1 with SMTP id h1so23733688pdr.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 14:13:36 -0700 (PDT)
Date: Thu, 13 Aug 2015 14:13:33 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH v4 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150813211333.GD8588@Sligo.logfs.org>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1439365520-12605-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1439365520-12605-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.10.1508121327290.5382@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1508121327290.5382@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Aug 12, 2015 at 01:30:27PM -0700, David Rientjes wrote:
> 
> I'd be interested in the comments of others, though, to see if there is 
> any reservation about the hstate size breakdown.  It may actually find no 
> current customer who is interested in parsing it.  (If we keep it, I would 
> suggest the 'x' change to '*' similar to per-order breakdowns in 
> show_mem()).  It may also be possible to add it later if a definitive 
> usecase is presented.

I have no interest in parsing the size breakdown today.  I might change
my mind tomorrow and having the extra information hurts very little, so
I won't argue against it either.

> But overall I'm very happy with the new addition and think it's a good 
> solution to the problem.

Agreed.  Thank you!

Jorn

--
One of the painful things about our time is that those who feel certainty
are stupid, and those with any imagination and understanding are filled
with doubt and indecision.
-- Bertrand Russell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
