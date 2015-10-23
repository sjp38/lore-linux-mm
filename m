Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5060B6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 23:54:18 -0400 (EDT)
Received: by qkbl190 with SMTP id l190so65371028qkb.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 20:54:18 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id n85si16813755qki.65.2015.10.22.20.54.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 20:54:17 -0700 (PDT)
Received: by qkbl190 with SMTP id l190so65370904qkb.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 20:54:17 -0700 (PDT)
Date: Thu, 22 Oct 2015 23:54:10 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v11 02/14] HMM: add special swap filetype for memory
 migrated to device v2.
Message-ID: <20151023035409.GA4404@gmail.com>
References: <05ec01d10c9b$4df7ba80$e9e72f80$@alibaba-inc.com>
 <05f501d10c9e$a8562900$f9027b00$@alibaba-inc.com>
 <20151022142144.GB2914@redhat.com>
 <070501d10d42$2ec35190$8c49f4b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <070501d10d42$2ec35190$8c49f4b0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Jerome Glisse' <jglisse@redhat.com>, linux-mm@kvack.org, 'linux-kernel' <linux-kernel@vger.kernel.org>

On Fri, Oct 23, 2015 at 11:23:26AM +0800, Hillf Danton wrote:
> > > > +	if (cnt_hmm_entry) {
> > > > +		int ret;
> > > > +
> > > > +		ret = hmm_mm_fork(src_mm, dst_mm, dst_vma,
> > > > +				  dst_pmd, start, end);
> > >
> > > Given start, s/end/addr/, no?
> > 
> > No, end is the right upper limit here.
> > 
> Then in the first loop, hmm_mm_fork is invoked for
> the _entire_ range, from input addr to end.
> In subsequent loops(if necessary), start is updated to
> addr, and hmm_mm_fork is also invoked for remaining
> range, from start to end.
> 
> Is the above overlap in range making sense?

Well yes and no, hmm_mm_fork() will do nothing for address >= addr
i feel like end is easier to understand.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
