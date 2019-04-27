Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A551C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:53:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03B1A206BA
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:53:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="anuLVemm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03B1A206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 961C76B0003; Fri, 26 Apr 2019 21:53:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E83F6B0006; Fri, 26 Apr 2019 21:53:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 789416B000A; Fri, 26 Apr 2019 21:53:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 486816B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:53:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g6so3027179plp.18
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:53:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=C0VKk+EAi5u5Uun6wBIN+muqXBgzzEs95GkHwVG5AAA=;
        b=plovU+DUgDgj62/7fkSmG22ylj0JwBQ89BqyMeCSfLuoCcoINcmd/6XqteyFarejsj
         /bec9inHXtX6BOJ43PZP7XHD4WVuc4w0ZZvpmeQUXU1B1PmUb1HWVfpYjFfiyl4Ncg/p
         2ynaYXstrXVH32AncJfOWzba2iJVLOva+NW2PCSgxq7uxpqdvS6pWHiaQH39CRK1oojb
         OUAKOk3/3WKFzajLGoZ38zoBhRldP7TrGS4LrRGmIO/oxCmgUIuKXi2hRM0o3+WZ+T6S
         vfkR5jeQmxrC1xPdR7o+Wlq6yvfY4WJ6OM5H/Jh32Vewd19akPHbfyidMWPXEmK/C/vX
         L/lA==
X-Gm-Message-State: APjAAAVHRmv+0VrUJh/ccalSCa81ttus/2NTBllxLy3x3s2r591/wzuV
	XXuNND5xntIIthuCSfOx8DEpuSzZVDL1D8eAEjar9KrE/VvPME9rNzBLixl5tHuB+zw800NqfYC
	xQcP88lp7XED+MF/+s+HyteqmyIyuOP/X+N4/KpL4U7auMtMOk+rZFo0+omZo44WBXg==
X-Received: by 2002:a65:6088:: with SMTP id t8mr47232590pgu.2.1556330001917;
        Fri, 26 Apr 2019 18:53:21 -0700 (PDT)
X-Received: by 2002:a65:6088:: with SMTP id t8mr47232544pgu.2.1556330001100;
        Fri, 26 Apr 2019 18:53:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556330001; cv=none;
        d=google.com; s=arc-20160816;
        b=yVL73kIRJzGAeiPcJ+tOeF9LbENnmtfHV9CHt9YBaq5JOqa71bwy5njdd2uZTtsQf+
         NUUgiBLDu75VvwmyPkp38F/eEyP8lE2QgP+p5Zf9NOkJdITzDGf9Vpt9+RdH8PmhFmqx
         Kazh7NKvJN6oUTFdZTc03RKz3bcGsZW2AGoYAJC8SVheSztJfcV/NkDnBbme07MBUcgr
         2qDPv6BSlP7eKhQud2ybqjL0nnLjZckX1phmGbOzBYOvpYWOqWt3LaNYUlTjCGN/sUnH
         WZskzm3D4C68o4YNFXaWMKPShL0hVZunnAQxyNHW49R+4TYKOaaBu6zTN0/sSvHnQEPQ
         ycjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=C0VKk+EAi5u5Uun6wBIN+muqXBgzzEs95GkHwVG5AAA=;
        b=cr/+QlrlS5YnyAH0iRYHqETkjrDeciX1Ncaof1pdRT7j7cSQR7jZ6yX1Y7YH3ZYFnm
         mdscyNpy9p1gCifZJEaTL8Q71ef8qE/g83XpGpV1Xyei4dl/infBiAsoJEwyLZID85lq
         lgGiGJBES1n8znHbTbWQIQW/p331kXctl/7ga6O/FE2/toba/wviTaVmJvZc6Hmj5MQe
         BVbumlxBCtHY+XUK3aQB4iPo8kUETRAkutmKbMyzCmUhNje7L1jLSyCY0sJvUq4Xipg0
         454T/cNrTt0CS+mhSWQf6bYgSyesa8vUPS0MYT7UQUa18wy7qTl0qWIQ6SSR6CWnjSIu
         T9ZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=anuLVemm;
       spf=pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=walken@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cl14sor25934729plb.30.2019.04.26.18.53.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 18:53:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=anuLVemm;
       spf=pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=walken@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=C0VKk+EAi5u5Uun6wBIN+muqXBgzzEs95GkHwVG5AAA=;
        b=anuLVemm2cS9eYF8xrdrwSlIQY4mMWHdXLDko+6AmctdVHFyF5pQaGa1SeN03K7rrV
         OCNQzJvzftqVbUoLyHTYPZBbUnfJcKDZ5UdXqXHSKsGDdAWUglACEGTREID86yWfbit9
         dVLK7b97qd2DLolrjLXXfo2U5j3jMBwunkG8+NqUhpUllSrofHUg02I7+bbDVIAtTCii
         5/YFx7IoojLdfRZ37NfXOGWRI39lUQQL3a2F9NsFiAS/QJJpqxZCxHBLdMC9oHJWqACB
         PJm6bC6+IXoHRaW55sgvw2UwKZGVHppqkASMv3q6vxVLu3vCMSw2zpVYFG1iFY+IyFsO
         Kfsg==
X-Google-Smtp-Source: APXvYqzLc91mh/R/1sCU3aj6tk7P3taVwaDKlm61Xk6iVK1dTUs3AnXwhAqNlKEB6ez6miyXsn0kYQ==
X-Received: by 2002:a17:902:7206:: with SMTP id ba6mr14556564plb.301.1556330000083;
        Fri, 26 Apr 2019 18:53:20 -0700 (PDT)
Received: from google.com ([2620:15c:2cd:202:668d:6035:b425:3a3a])
        by smtp.gmail.com with ESMTPSA id f63sm46374543pfc.180.2019.04.26.18.53.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 18:53:17 -0700 (PDT)
Date: Fri, 26 Apr 2019 18:53:15 -0700
From: Michel Lespinasse <walken@google.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Andi Kleen <ak@linux.intel.com>, dave@stgolabs.net,
	Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	mpe@ellerman.id.au, Paul Mackerras <paulus@samba.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Mike Rapoport <rppt@linux.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	haren@linux.vnet.ibm.com, Nick Piggin <npiggin@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 00/31] Speculative page faults
Message-ID: <20190427015315.GA174296@google.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
 <20190423093851.GJ11158@hirez.programming.kicks-ass.net>
 <05df6720-7130-62fe-a71f-074b6fafff3e@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <05df6720-7130-62fe-a71f-074b6fafff3e@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 09:33:44AM +0200, Laurent Dufour wrote:
> Le 23/04/2019 à 11:38, Peter Zijlstra a écrit :
> > On Mon, Apr 22, 2019 at 02:29:16PM -0700, Michel Lespinasse wrote:
> > > The proposed spf mechanism only handles anon vmas. Is there a
> > > fundamental reason why it couldn't handle mapped files too ?
> > > My understanding is that the mechanism of verifying the vma after
> > > taking back the ptl at the end of the fault would work there too ?
> > > The file has to stay referenced during the fault, but holding the vma's
> > > refcount could be made to cover that ? the vm_file refcount would have
> > > to be released in __free_vma() instead of remove_vma; I'm not quite sure
> > > if that has more implications than I realize ?
> > 
> > IIRC (and I really don't remember all that much) the trickiest bit was
> > vs unmount. Since files can stay open past the 'expected' duration,
> > umount could be delayed.
> > 
> > But yes, I think I had a version that did all that just 'fine'. Like
> > mentioned, I didn't keep the refcount because it sucked just as hard as
> > the mmap_sem contention, but the SRCU callback did the fput() just fine
> > (esp. now that we have delayed_fput).
> 
> I had to use a refcount for the VMA because I'm using RCU in place of SRCU
> and only protecting the RB tree using RCU.
> 
> Regarding the file pointer, I decided to release it synchronously to avoid
> the latency of RCU during the file closing. As you mentioned this could
> delayed the umount but not only, as Linus Torvald demonstrated by the past
> [1]. Anyway, since the file support is not yet here there is no need for
> that currently.
>
> [1] https://lore.kernel.org/linux-mm/alpine.LFD.2.00.1001041904250.3630@localhost.localdomain/

Just to make sure I understand this correctly. If a program tries to
munmap a region while page faults are occuring (which means that the
program has a race condition in the first place), before spf the
mmap_sem would delay the munmap until the page fault completes. With
spf the munmap will happen immediately, while the vm_ops->fault()
is running, with spf holding a ref to the file. vm_ops->fault is
expected to execute a read from the file to the page cache, and the
page cache page will never be mapped into the process because after
taking the ptl, spf will notice the vma changed.  So, the side effects
that may be observed after munmap completes would be:

- side effects from reading a file into the page cache - I'm not sure
  what they are, the main one I can think of is that userspace may observe
  the file's atime changing ?

- side effects from holding a reference to the file - which userspace
  may observe by trying to unmount().

Is that the extent of the side effects, or are there more that I have
not thought of ?

> Regarding the file mapping support, the concern is to ensure that
> vm_ops->fault() will not try to release the mmap_sem. This is true for most
> of the file system operation using the generic one, but there is currently
> no clever way to identify that except by checking the vm_ops->fault pointer.
> Adding a flag to the vm_operations_struct structure is another option.
> 
> that's doable as far as the underlying fault() function is not dealing with
> the mmap_sem, and I made a try by the past but was thinking that first the
> anonymous case should be accepted before moving forward this way.

Yes, that makes sense. Updating all of the fault handlers would be a
lot of work - but there doesn't seem to be anything fundamental that
wouldn't work there (except for the side effects of reordering spf
against munmap, as discussed above, which doesn't look easy to fully hide.).

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

