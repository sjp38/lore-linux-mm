Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF5556B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 05:42:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c23so381854953pfj.0
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 02:42:31 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id e67si3533256pfa.169.2017.03.23.02.42.29
        for <linux-mm@kvack.org>;
        Thu, 23 Mar 2017 02:42:31 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1490207346-9703-1-git-send-email-a.perevalov@samsung.com> <CGME20170322182918eucas1p204ef2f7aadb0ac41d11f15ef434c74c4@eucas1p2.samsung.com> <1490207346-9703-2-git-send-email-a.perevalov@samsung.com>
In-Reply-To: <1490207346-9703-2-git-send-email-a.perevalov@samsung.com>
Subject: Re: [PATCH v2] userfaultfd: provide pid in userfault msg
Date: Thu, 23 Mar 2017 17:42:16 +0800
Message-ID: <00af01d2a3b9$c23b5030$46b1f090$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Alexey Perevalov' <a.perevalov@samsung.com>, 'Andrea Arcangeli' <aarcange@redhat.com>
Cc: "'Dr . David Alan Gilbert'" <dgilbert@redhat.com>, linux-mm@kvack.org, i.maximets@samsung.com

On March 23, 2017 2:29 AM Alexey Perevalov wrote:
> 
>  static inline struct uffd_msg userfault_msg(unsigned long address,
>  					    unsigned int flags,
> -					    unsigned long reason)
> +					    unsigned long reason,
> +					    unsigned int features)
Nit: the type of feature is u64 by define.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
