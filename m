Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70F62C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:58:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B501217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:58:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="u8sRhP8b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B501217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A9866B0003; Wed,  7 Aug 2019 16:58:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 959436B0006; Wed,  7 Aug 2019 16:58:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 847EE6B0007; Wed,  7 Aug 2019 16:58:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 502026B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 16:58:43 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d190so57447085pfa.0
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 13:58:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j94Ug7s5ET6/R/IxgZElXz+z5GBfj769ZpmyDC2waXo=;
        b=tC3QNB7rm8j65YQ2elwUK+HghEwUr4C0BnrQdByhwPsGHj8HjAp9WYuX6M5uwxvezD
         5rm5SWW35ObkQbH5Cixsi4S+EPWjKYAaGn2UJq9XmFGoYbNUAskQJCrTnP5Wbm2wWj+F
         EwaX4DZ/BQpItZZ0eggbwHr6ZCpMO+6UMaSoNdkrLErat0yhg2iPNBpGKpwdBUaLfALq
         u/Xs8rmweao1mJkGAevjuDNklHc/aFrGsFC1cU4YpBxID0HGYvPdpVFu2CxaIWUJSIxM
         H29qvJZQeNY3/V9DUR1HR0Y+aQAtsxg3lVO/t3YuT4xNQrASDLBq8qrMX5BeLc4BIoip
         WKHQ==
X-Gm-Message-State: APjAAAUWENEp/OScvWYXkK06CXkIM0dDx3L8Yafi5CljSS3d1XIn9ZNv
	ipn4d9zyeP55WLxK1pIX+s/amgqGwGUzXo/uvIscX3NbG9blRFkZPsX9FuRF38rePEAiN2t1tbZ
	ndGhl97CApXcJ9ZbbOpfunFh0hIS6kHbE0Jqx2U2OZ0e5mtxvruLRXUCn8Ovf8f0cBQ==
X-Received: by 2002:a17:902:44f:: with SMTP id 73mr10134280ple.192.1565211522742;
        Wed, 07 Aug 2019 13:58:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdaST+K3gG5bZfK4EgJKq2Lvwi5h+kHyxuPzAcaan+TJ41jUO0o5CAl4CGmXdHC/Q0N47N
X-Received: by 2002:a17:902:44f:: with SMTP id 73mr10134237ple.192.1565211522009;
        Wed, 07 Aug 2019 13:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565211522; cv=none;
        d=google.com; s=arc-20160816;
        b=kwltWj4sBEszu8z4TqROgDVgp0NY+k65xO52cQvqeogHkpemd/HfwZYXBpDpY/j3kr
         AIizksdL/pYD1kS7dZR8+Oeh4Rmqske+FGSwFrCv6Eam0y+5ZGlsi6AxtoDwp2K5mJsl
         gL23CGrwv2oadV0n/HjwOUISoKvSTOJa3wPLlqszwBTH4kxCodowdYmqzQVeH8OBQJdz
         pGpn1LbwghjSpmRGuN15fIEuO0jmh/VcSIrf1Q/S8zd/WIjkJJ9pf7viRCN/A36iYHc6
         AirmJlT3qBdPg3VEshrIK+4rSsaq3EMdpCjhOeOuhtqtN5PPZLsWaJPIsLPk70mdAVeS
         Eaqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=j94Ug7s5ET6/R/IxgZElXz+z5GBfj769ZpmyDC2waXo=;
        b=KqddRhYADTD8PZeP3tEcRbUIteQqpITTlJoHgpzY7oFe1bxgjcsJPkOOdgE7iyINZ9
         MrKurExF1VmEE6mkkWqBGd/Tydvpphrec0t+ZCSyIVdAob8ptYlzAC+jHHjGO7gXakh3
         EKSf/apBrtxKLmhUfcCxGUj1LpgT/C3CBCJmRNXF4n/+urjVb3WjDzI2nRhfh4C3lw67
         2ZSzPiYc26OAaPHW/JU6cDyeFY9+R/ApTG2bOGM78W+5Hj3A/vGjxIsTXv/G53u8nvbJ
         pLVVlFZ5N4o6rwUDfCuuSFQPY9WGt+mTZk3G4Buq8eTB6mT8BLGneXNSTxRwbs2/UXGh
         LJ/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=u8sRhP8b;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j190si52628217pge.92.2019.08.07.13.58.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 13:58:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=u8sRhP8b;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8357A2173C;
	Wed,  7 Aug 2019 20:58:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565211521;
	bh=BHNLhewizLMLp7YbdvNCnIzAyhkg8YnrouHHCEfoVa4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=u8sRhP8bK815tFw7ifhBS4SB17zcgKZ47zrUXrczJIScpe3WeCh14v/46lx0CCeRW
	 0rylwHRSL91S/Vbfj1YBHXKkOsfP1dbUn9GG5ygIrbrkQElQQjhhVbQw/U11jkcUcy
	 /6UT11ZTtKTBTxqWUlh1WwFRaVjP4y6LQYMuaHYg=
Date: Wed, 7 Aug 2019 13:58:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
 Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>, Catalin
 Marinas <catalin.marinas@arm.com>, Christian Hansen <chansen3@cisco.com>,
 dancol@google.com, fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>, kernel-team@android.com,
 linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko
 <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
 namhyung@google.com, paulmck@linux.ibm.com, Robin Murphy
 <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>, Stephen Rothwell
 <sfr@canb.auug.org.au>, surenb@google.com, Thomas Gleixner
 <tglx@linutronix.de>, tkjos@google.com, Vladimir Davydov
 <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon
 <will@kernel.org>
Subject: Re: [PATCH v5 1/6] mm/page_idle: Add per-pid idle page tracking
 using virtual index
Message-Id: <20190807135840.92b852e980a9593fe91fbf59@linux-foundation.org>
In-Reply-To: <20190807204530.GB90900@google.com>
References: <20190807171559.182301-1-joel@joelfernandes.org>
	<20190807130402.49c9ea8bf144d2f83bfeb353@linux-foundation.org>
	<20190807204530.GB90900@google.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Aug 2019 16:45:30 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:

> On Wed, Aug 07, 2019 at 01:04:02PM -0700, Andrew Morton wrote:
> > On Wed,  7 Aug 2019 13:15:54 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> > 
> > > In Android, we are using this for the heap profiler (heapprofd) which
> > > profiles and pin points code paths which allocates and leaves memory
> > > idle for long periods of time. This method solves the security issue
> > > with userspace learning the PFN, and while at it is also shown to yield
> > > better results than the pagemap lookup, the theory being that the window
> > > where the address space can change is reduced by eliminating the
> > > intermediate pagemap look up stage. In virtual address indexing, the
> > > process's mmap_sem is held for the duration of the access.
> > 
> > So is heapprofd a developer-only thing?  Is heapprofd included in
> > end-user android loads?  If not then, again, wouldn't it be better to
> > make the feature Kconfigurable so that Android developers can enable it
> > during development then disable it for production kernels?
> 
> Almost all of this code is already configurable with
> CONFIG_IDLE_PAGE_TRACKING. If you disable it, then all of this code gets
> disabled.
> 
> Or are you referring to something else that needs to be made configurable?

Yes - the 300+ lines of code which this patchset adds!

The impacted people will be those who use the existing
idle-page-tracking feature but who will not use the new feature.  I
guess we can assume this set is small...


