Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D912DC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:18:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F7812177E
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:18:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="cWBMS3PZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F7812177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26AE06B0006; Wed, 22 May 2019 17:18:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F4736B0007; Wed, 22 May 2019 17:18:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BDE06B0008; Wed, 22 May 2019 17:18:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C27416B0006
	for <linux-mm@kvack.org>; Wed, 22 May 2019 17:18:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s8so2419185pgk.0
        for <linux-mm@kvack.org>; Wed, 22 May 2019 14:18:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xBlxGTGLhDHKTdapGjfzSxUkvnAgB8aV2NBqH4W5GOU=;
        b=ogwx/D5GN4Q+YAMqjPAZQSdzpjCXVED6+/c9ozl2M7osY211vLbIOjpAiWY4LGbEoY
         EummY75aaFyeMy8yw0URoJvFCz6+sJIJnzPNAwaM5VTrtgg2brob7uW4G2OHf/iNzNGw
         3uZsBah5ROsMrck/eyX6Gdu+sWwEwbry/SBcqoQu8Fle+1lgTpFGmyrMdEIKe5Gyl+qQ
         WQ9Q/m2iVmvDpDYsvfqee75hEantfAux2Vth8wYw73uRnjwIr0MeuLx6sba83zqX9z4F
         ytz+L8IIm60GEOTSmV63rDgZiaijrNwYpJGykFulw3aJ4eC1Ro12nT02uN5KaP90J201
         ulSw==
X-Gm-Message-State: APjAAAU2uG7S8cwsWtg49qSewKUZuavx9u8Yjhr/OlHYzQ03/MesXC2O
	His9JLHM7N/Ht8wDR05o1Uuco9y6jxvNTbK7vv0/X3j7cMg1ZepSqqr9Wnqv4bm20Afbi6YClAu
	Hi3zWrRI6ofH89ebl2mH4RU058bazenS3SBi+G93hBlcvGy6zSpwbwU/03CXjTvkk8Q==
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr48904429pls.50.1558559885384;
        Wed, 22 May 2019 14:18:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSHwDEn19b1Tf2tUuSh0ulQzaZxMtBUkM5hWawMcaIALRoEx0hk+zm85HzfdpqdGgVQXxn
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr48904370pls.50.1558559884468;
        Wed, 22 May 2019 14:18:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558559884; cv=none;
        d=google.com; s=arc-20160816;
        b=ZU3OoL0f4wqZWBoPRLUMjTCOjDDrqzercyPYATj3w10iZ9bH40txsPO1x0+OYcWKmH
         cGEvs8tJcmBZIYGtXRgkejlWPjTrv7gtGALQZ/BO3hYZNDQQqZGjHiP+ZoPltQP8YXr+
         p0jU07yHxwNrDR7ao7JpFH881KNIbS9wG6mKJS15RYmYcxLfHUn/GVluehxNcUxp1DWU
         LRz86LS8GBWZHanUuNcGnaqo4pgJTEo+4I7KUGON4DtrFXtAeMTpv2ClXteH35PqH7JM
         HiD7/4qZZhb2fA4I67/U0Hbqb+yj/RWOBg6gbrE9eQvzCt754xXrNQLP1rWXVMi1wQ/v
         +NiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xBlxGTGLhDHKTdapGjfzSxUkvnAgB8aV2NBqH4W5GOU=;
        b=a5ybOQQC+9IYGCCQdjUkNi7rj4kagnoZReqVukGDeHRfzgj3FFUQumZf97RemXga1L
         dicbr7l2Mi2i9Ieo8HHJ1qDd46aDPDII8v8tjwzXKvYW8JMj6coPGqHT8MWmABfVA+9M
         3I26Z8ZVm6FKq71BvUBLIgWtM0IccNcPWXtDXp5uGS5WCUxdL6Jdy0BtrkfR9xENPsRQ
         5caujN+MYeKAV3pmkMFvRe+XhRiVqipdi3WCOqZnCq1Jjx/XOcvzt+b0MU17ZBDy3+mS
         3Lk5nY22+cWa1f/BLouQIbqhWulkF30pkZrv15eFUYU3zFTqJSp23NX7+ui+udqd9Mns
         prjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cWBMS3PZ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h18si25852462plr.16.2019.05.22.14.18.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 14:18:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cWBMS3PZ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9878B2173E;
	Wed, 22 May 2019 21:18:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558559883;
	bh=vm5TFptU4z16aOaq6WyJVuLQG+smQSsecNHc6EdO2EQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=cWBMS3PZhojaDwCxM24fm9eZtn2egLd4rKSnhyyfFkuHkE9NM/B7vOwsCfa4hFLGr
	 uBaSKoEy87eBUtvEQ4U3tKU9B0eI9hYynsiUeYbH9IeamI/gPYa5UnGJ8MDzTEXSLm
	 uv2bfg9jqE4iHSK1DBHm1Bj5munpo/iw6Bx190H4=
Date: Wed, 22 May 2019 14:18:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Sebastian Andrzej Siewior
 <bigeasy@linutronix.de>, Borislav Petkov <bp@suse.de>,
 "Dr. David Alan Gilbert" <dgilbert@redhat.com>, kvm@vger.kernel.org
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
Message-Id: <20190522141803.c6714f96f57612caaac5d19b@linux-foundation.org>
In-Reply-To: <20190522203828.GC18865@rapoport-lnx>
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
	<20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org>
	<20190522203828.GC18865@rapoport-lnx>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 May 2019 23:38:29 +0300 Mike Rapoport <rppt@linux.ibm.com> wrote:

> (added kvm)
> 
> On Wed, May 22, 2019 at 12:21:13PM -0700, Andrew Morton wrote:
> > On Tue, 14 May 2019 17:29:55 +0300 Mike Rapoport <rppt@linux.ibm.com> wrote:
> > 
> > > When get_user_pages*() is called with pages = NULL, the processing of
> > > VM_FAULT_RETRY terminates early without actually retrying to fault-in all
> > > the pages.
> > > 
> > > If the pages in the requested range belong to a VMA that has userfaultfd
> > > registered, handle_userfault() returns VM_FAULT_RETRY *after* user space
> > > has populated the page, but for the gup pre-fault case there's no actual
> > > retry and the caller will get no pages although they are present.
> > > 
> > > This issue was uncovered when running post-copy memory restore in CRIU
> > > after commit d9c9ce34ed5c ("x86/fpu: Fault-in user stack if
> > > copy_fpstate_to_sigframe() fails").
> > > 
> > > After this change, the copying of FPU state to the sigframe switched from
> > > copy_to_user() variants which caused a real page fault to get_user_pages()
> > > with pages parameter set to NULL.
> > 
> > You're saying that argument buf_fx in copy_fpstate_to_sigframe() is NULL?
> 
> Apparently I haven't explained well. The 'pages' parameter in the call to
> get_user_pages_unlocked() is NULL.

Doh.

> > If so was that expected by the (now cc'ed) developers of
> > d9c9ce34ed5c8923 ("x86/fpu: Fault-in user stack if
> > copy_fpstate_to_sigframe() fails")?
> > 
> > It seems rather odd.  copy_fpregs_to_sigframe() doesn't look like it's
> > expecting a NULL argument.
> > 
> > Also, I wonder if copy_fpstate_to_sigframe() would be better using
> > fault_in_pages_writeable() rather than get_user_pages_unlocked().  That
> > seems like it operates at a more suitable level and I guess it will fix
> > this issue also.
> 
> If I understand correctly, one of the points of d9c9ce34ed5c8923 ("x86/fpu:
> Fault-in user stack if copy_fpstate_to_sigframe() fails") was to to avoid
> page faults, hence the use of get_user_pages().
> 
> With fault_in_pages_writeable() there might be a page fault, unless I've
> completely mistaken.
> 
> Unrelated to copy_fpstate_to_sigframe(), the issue could happen if any call
> to get_user_pages() with pages parameter set to NULL tries to access
> userfaultfd-managed memory. Currently, there are 4 in tree users:
> 
> arch/x86/kernel/fpu/signal.c:198:8-31:  -> gup with !pages
> arch/x86/mm/mpx.c:423:11-25:  -> gup with !pages
> virt/kvm/async_pf.c:90:1-22:  -> gup with !pages
> virt/kvm/kvm_main.c:1437:6-20:  -> gup with !pages

OK.

> I don't know if anybody is using mpx with uffd and anyway mpx seems to go
> away.
> 
> As for KVM, I think that post-copy live migration of L2 guest might trigger
> that as well. Not sure though, I'm not really familiar with KVM code.
>  
> > > In post-copy mode of CRIU, the destination memory is managed with
> > > userfaultfd and lack of the retry for pre-fault case in get_user_pages()
> > > causes a crash of the restored process.
> > > 
> > > Making the pre-fault behavior of get_user_pages() the same as the "normal"
> > > one fixes the issue.
> > 
> > Should this be backported into -stable trees?
> 
> I think that it depends on whether KVM affected by this or not.
> 

How do we determine this?

I guess it doesn't matter much.

