Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B58DD6B0333
	for <linux-mm@kvack.org>; Sun, 26 Mar 2017 23:57:59 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g124so25512103pgc.1
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 20:57:59 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id x188si11241495pgb.304.2017.03.26.20.57.57
        for <linux-mm@kvack.org>;
        Sun, 26 Mar 2017 20:57:58 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1490207346-9703-1-git-send-email-a.perevalov@samsung.com> <CGME20170322182918eucas1p204ef2f7aadb0ac41d11f15ef434c74c4@eucas1p2.samsung.com> <1490207346-9703-2-git-send-email-a.perevalov@samsung.com> <00af01d2a3b9$c23b5030$46b1f090$@alibaba-inc.com> <105a751b-254a-d2e3-441e-1418a8e30905@samsung.com>
In-Reply-To: <105a751b-254a-d2e3-441e-1418a8e30905@samsung.com>
Subject: Re: [PATCH v2] userfaultfd: provide pid in userfault msg
Date: Mon, 27 Mar 2017 11:57:43 +0800
Message-ID: <015d01d2a6ae$4a3abf10$deb03d30$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Alexey Perevalov' <a.perevalov@samsung.com>, 'Andrea Arcangeli' <aarcange@redhat.com>
Cc: "'Dr . David Alan Gilbert'" <dgilbert@redhat.com>, linux-mm@kvack.org, i.maximets@samsung.com


On March 25, 2017 7:48 PM Alexey Perevalov wrote:
> On 03/23/2017 12:42 PM, Hillf Danton wrote:
> > On March 23, 2017 2:29 AM Alexey Perevalov wrote:
> >>   static inline struct uffd_msg userfault_msg(unsigned long address,
> >>   					    unsigned int flags,
> >> -					    unsigned long reason)
> >> +					    unsigned long reason,
> >> +					    unsigned int features)
> > Nit: the type of feature is u64 by define.
> 
> Yes, let me clarify once again,

Thanks:)

> type of features is u64, but in struct uffdio_api, which used for handling
> UFFDIO_API.
> Function userfault_msg is using in handle_userfault, when only
> context (struct userfaultfd_ctx) is available, features inside context is
> type of unsigned int and uffd_ctx_features is using for casting.
> It's more likely question to maintainer, but due to userfaultfd_ctx is
> internal only
> structure, it's not a big problem to extend it in the future.
> 
You are right.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
