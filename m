Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCEBFC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 17:51:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F9D12087E
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 17:51:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="mcakECUM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F9D12087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08AA16B0003; Mon, 25 Mar 2019 13:51:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 013B76B0006; Mon, 25 Mar 2019 13:51:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1E806B0007; Mon, 25 Mar 2019 13:51:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAE6C6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 13:51:54 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id w124so6596068qkb.12
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:51:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=00Ms6NJY8XZVY3PTifw/DWKACkhTufevyM9oDDMnZ98=;
        b=pywToN5FVdThOP7Z1Za14i5IXC24gaUsP603y1ya8fztPRDkXDRz6Mzk2+BEHx88gJ
         F8HfmVZaCx2pEFVq3g9O/GA3lcqLbxythU+wpLeutNG5c1QccgwkYj8hmEqL+TBYbr3I
         058NYQ0UC+JPo0xprz8CuqQ5c2d5rPfPsm2AyL0ynI+lahXnkczOduKOWNVtzDYf5SCI
         59PBtC89JE1I50JR1i+MLpYPvALvXk0gHJtIIVQqJxuq/FT8FOicpjEDdzsZ3n+N7I3k
         lnhrUrEuTOahNsQOEVvvssg/eBa1JVh83xhTB8U/rhliXtT52ENccPTOUOhArKRISSNc
         MTbA==
X-Gm-Message-State: APjAAAXDSK8IWbxLarDIVRhUNylEA+7SGpP4tD2Trzp79jAZ48cihnGr
	jBMb2Xmv4Dw1O3cO8TeHbcw7FEW7bfA3vjsjzdXjpOj5fBh1OFdEqKianZ+mGBMRqMMm13+BHnE
	XyHdNQnUm9vAmF/Q4+imb7MTONM2FkzoAuWGnLI9XjVNxAPl4NJZGQDs/bmG1bWL2KQ==
X-Received: by 2002:a0c:904b:: with SMTP id o69mr21805091qvo.244.1553536314404;
        Mon, 25 Mar 2019 10:51:54 -0700 (PDT)
X-Received: by 2002:a0c:904b:: with SMTP id o69mr21804995qvo.244.1553536312698;
        Mon, 25 Mar 2019 10:51:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553536312; cv=none;
        d=google.com; s=arc-20160816;
        b=n8yJpyBT6SDPqT1VhS8XuF9E2BhKHubV8F/IbzXiPW3L6/EMZYbbCAudH2TfJj1CkJ
         Bx++XeMKqccbPrP5PXPSu59HqjbcFZiQZAToQYHs+yVJXABH0+o0OvVnZRlzvNWMSbaU
         KrPOGJqnkslePQhQ2AvvPOrZnneUjnLaP+uMgF2z/Lc2AzIOak5jbwjz0mGLFroJnzEm
         zJLXSvOBMPUAjvbM7DoyaEt5GDCweKd1LaCmcOZ43PEslf08rNkgM38bJBRJ0JZw3Hxw
         hYdJg7FnKZn0Qnt0Y05yfF/pNorChG8QRTOQ4QmDaAXQHok3pQiVMbkdpgzDlz6c/TGz
         h5cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=00Ms6NJY8XZVY3PTifw/DWKACkhTufevyM9oDDMnZ98=;
        b=k/iuDGIKCuXt2P4VrwTs1HRH2OQTuF7HqEIzXlt58My6/oSJFHM6INr018IIA53DOC
         nz0WqFhammjMoDR/CPDbDWrrj70EK0hpZn4wnDguOo+TM8HMM8cC7UG0nfd2H3EcYAwx
         u9R1U1Vnlxe1zXqkTHeHn/oojzcCxOCu0T1dfHeRcd4NkL+f2Ao/JvrGcbl62aa4TMO6
         nHNBjDRan08CacLHXsTSoGoufXMXn/7dj1bv4103tyceXgAU49OqM1L1F6iJUxOCBXGb
         QCqwC8HAPa0PJkfQEbilsIOKSMCMPjsDudMfBqCY15V+5cYIVc0T/PthFMf4WqFssJm2
         QMYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=mcakECUM;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p124sor2740607qkf.128.2019.03.25.10.51.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 10:51:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=mcakECUM;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=00Ms6NJY8XZVY3PTifw/DWKACkhTufevyM9oDDMnZ98=;
        b=mcakECUMzfnWJTjHKTgjHkQ3p5HiWz1AVOeK/ghfgih69htVJO9HDrS54A121ygzVY
         gWLEZMejpsvVFhPFvHwICPJEGrqNyF2/qZcA0NNQdr9DSe7lhxSeAsy3AlI8/ilXz0Wy
         iMjTD05URcYKbnMgowRxCxL/DBUygVp3Sma1XI81k+r9M7o2AAzJzmYJzZpoi21aczm0
         eJeHxiLWuI7hbyS8S+/ZQ0NvTbpWGm3bLAR63L4Lfuo8GetXjU127prX/mYb1aNddl8p
         PasZzEsnYa7YcrBr5PZX7TvDDfzStRfR4EBtHmAXdccRPyo5CD2MDBXpy7Y6pvzdL9FQ
         Mskw==
X-Google-Smtp-Source: APXvYqyPXE4H1Qt/wLb7MTNtAAHDbeoOG7ue4zLWhXEM5KYve0v2wSXPQ09LZ4L0EFTQCEmHdQgrlA==
X-Received: by 2002:a37:7d86:: with SMTP id y128mr20700103qkc.36.1553536312325;
        Mon, 25 Mar 2019 10:51:52 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id 56sm5277027qto.57.2019.03.25.10.51.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Mar 2019 10:51:51 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1h8TlG-0005vR-FG; Mon, 25 Mar 2019 14:51:50 -0300
Date: Mon, 25 Mar 2019 14:51:50 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mips@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: [RESEND 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
Message-ID: <20190325175150.GA21008@ziepe.ca>
References: <20190317183438.2057-1-ira.weiny@intel.com>
 <20190317183438.2057-5-ira.weiny@intel.com>
 <CAA9_cmcx-Bqo=CFuSj7Xcap3e5uaAot2reL2T74C47Ut6_KtQw@mail.gmail.com>
 <20190325084225.GC16366@iweiny-DESK2.sc.intel.com>
 <20190325164713.GC9949@ziepe.ca>
 <20190325092314.GF16366@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325092314.GF16366@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 02:23:15AM -0700, Ira Weiny wrote:
> > > Unfortunately holding the lock is required to support FOLL_LONGTERM (to check
> > > the VMAs) but we don't want to hold the lock to be optimal (specifically allow
> > > FAULT_FOLL_ALLOW_RETRY).  So I'm maintaining the optimization for *_fast users
> > > who do not specify FOLL_LONGTERM.
> > > 
> > > Another way to do this would have been to define __gup_longterm_unlocked with
> > > the above logic, but that seemed overkill at this point.
> > 
> > get_user_pages_unlocked() is an exported symbol, shouldn't it work
> > with the FOLL_LONGTERM flag?
> > 
> > I think it should even though we have no user..
> > 
> > Otherwise the GUP API just gets more confusing.
> 
> I agree WRT to the API.  But I think callers of get_user_pages_unlocked() are
> not going to get the behavior they want if they specify FOLL_LONGTERM.

Oh? Isn't the only thing FOLL_LONGTERM does is block the call on DAX?
Why does the locking mode matter to this test?

> What I could do is BUG_ON (or just WARN_ON) if unlocked is called with
> FOLL_LONGTERM similar to the code in get_user_pages_locked() which does not
> allow locked and vmas to be passed together:

The GUP call should fail if you are doing something like this. But I'd
rather not see confusing specialc cases in code without a clear
comment explaining why it has to be there.

Jason

