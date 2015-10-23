Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 22A8F6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 23:23:42 -0400 (EDT)
Received: by pasz6 with SMTP id z6so104805050pas.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 20:23:41 -0700 (PDT)
Received: from out21.biz.mail.alibaba.com (out21.biz.mail.alibaba.com. [205.204.114.132])
        by mx.google.com with ESMTP id co2si26005081pbc.217.2015.10.22.20.23.39
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 20:23:41 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <05ec01d10c9b$4df7ba80$e9e72f80$@alibaba-inc.com> <05f501d10c9e$a8562900$f9027b00$@alibaba-inc.com> <20151022142144.GB2914@redhat.com>
In-Reply-To: <20151022142144.GB2914@redhat.com>
Subject: Re: [PATCH v11 02/14] HMM: add special swap filetype for memory migrated to device v2.
Date: Fri, 23 Oct 2015 11:23:26 +0800
Message-ID: <070501d10d42$2ec35190$8c49f4b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jerome Glisse' <jglisse@redhat.com>
Cc: linux-mm@kvack.org, 'linux-kernel' <linux-kernel@vger.kernel.org>

> > > +	if (cnt_hmm_entry) {
> > > +		int ret;
> > > +
> > > +		ret = hmm_mm_fork(src_mm, dst_mm, dst_vma,
> > > +				  dst_pmd, start, end);
> >
> > Given start, s/end/addr/, no?
> 
> No, end is the right upper limit here.
> 
Then in the first loop, hmm_mm_fork is invoked for
the _entire_ range, from input addr to end.
In subsequent loops(if necessary), start is updated to
addr, and hmm_mm_fork is also invoked for remaining
range, from start to end.

Is the above overlap in range making sense?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
