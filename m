Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id DF20B6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 14:09:03 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id kq13so435251pab.15
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 11:09:03 -0700 (PDT)
Date: Tue, 2 Apr 2013 11:09:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: THP: AnonHugePages in /proc/[pid]/smaps is correct or not?
In-Reply-To: <515ACDC9.2090506@gmail.com>
Message-ID: <alpine.DEB.2.02.1304021106190.17138@chino.kir.corp.google.com>
References: <383590596.664138.1364803227470.JavaMail.root@redhat.com> <alpine.DEB.2.02.1304011512490.17714@chino.kir.corp.google.com> <515ACDC9.2090506@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Zhouping Liu <zliu@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Amos Kong <akong@redhat.com>

On Tue, 2 Apr 2013, Simon Jeons wrote:

> Both thp and hugetlb pages should be 2MB aligned, correct?
> 

To answer this question and your followup reply at the same time: they 
come from one level higher in the page table so they will naturally need 
to be 2MB aligned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
