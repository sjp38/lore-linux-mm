Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AB46C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:43:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 224422083D
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:43:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 224422083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 925616B0005; Thu, 21 Mar 2019 09:43:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D4166B0006; Thu, 21 Mar 2019 09:43:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C3A06B0007; Thu, 21 Mar 2019 09:43:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFFA6B0005
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 09:43:42 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id l203so7745686ywb.11
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:43:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tPXTA3tExjHYvCl0U8yOGW77eTnvySzweHtIvbC5220=;
        b=SDhJze03mZh++R5k8Im8/4kE+QN7WyoGwaLF0tR4dxUwBh/d91I8pd8UtVVQVe0Y1a
         lhqqbFKes5IjOB2mgkAM1QaH/15d1Vf8l0mz9dY5724j+aTDB7S1Fkshn+dVYFj+P+hq
         CRybaiIQdqU2csO2j4NZ0zoGu8q6mSeTLYkYxrZUIXaUharzPTQIKkaNZEyiWAnQKyEL
         1U+6OY7LNoCU36MkRqtK2654PWmyd9+D7VFa/RQ024kOVG08NEsZmZKk8BulDz46tpML
         n19UXIEru5lJRlgtm0TPM6GLo9XT0V0OebBRKR+vqknPPnVmuA5zK5Fo88YfyPeURN40
         4TyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWZG0xqRXiYxKTtGyubIqbJt+llTA1yOANCT4eMNwxHfMiNhBvb
	LK0jFd/+RaIBy4necIh2jbhfbgB+SJpQU5kidbKVNLPaOR2lfIooo5KiTTOkWtmjgFb1K/83aAi
	daIMVxouCbk8qqzvzPqsXzfNxNVBMys4mFL1m7HZJlAj06ZJ4BpjJL4BG8hKpbEw=
X-Received: by 2002:a81:118f:: with SMTP id 137mr3111619ywr.330.1553175822168;
        Thu, 21 Mar 2019 06:43:42 -0700 (PDT)
X-Received: by 2002:a81:118f:: with SMTP id 137mr3111555ywr.330.1553175821317;
        Thu, 21 Mar 2019 06:43:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553175821; cv=none;
        d=google.com; s=arc-20160816;
        b=PKWTZyKXUFCB9fj1sNDeStDZx2/lIslmEwCSMpY8BoaX3At+oocIe5AK8FFnUdS4fu
         B+B2aj1k5YWqWWcBXBMosRRYN2rHUcko3sMsray+jeA680AhCyZv6XYvT9GumCv+R0Jb
         sT8Tf0mxq0x4CTf8k68gk/G15MujYj2l7+DPAuWBmhTd81yrqlm0fdK6kd3s2BErqs7h
         QMq+2lc3mLVgG1rBINgH3apSKhmuxGXGcSWcYc5uisvPZL449kow9R8scL0E7BFixNHV
         qJgXVFg8O7joGjfFkO4P0MCAzKf/vctFuAY8Gm/CT+N+Tekp7icJVr1buDteSof09+ir
         ymJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tPXTA3tExjHYvCl0U8yOGW77eTnvySzweHtIvbC5220=;
        b=s5zlhAc14ueVD/FqGnlkpKVUKqhY43r7w5wbYBTaDFxhsjZtkcTayqpu7tGf7si+om
         TdX0lcbIgi2OPudjdcqoulEbvDYFJAoq0Nt6whgLp2ziTgua0VRC3CcHrNP2zoR65KsA
         boZkM59SWcR8RHdt+jqBGz5rLKuM6SwuihKp2ikhpItN+cUWqtc6IbXWGjZsUEQ2hzR6
         PZpgnkRlRU4tj0zgnd/QsxUyK81bj0KzibV/FV4ZeC4+Kr4DtzGSA6+iql68CZqtCWrn
         zBcqTP2KLyUzctY6GsqB8s7oxyQkfhep+aFF2KQKyAqWXOgRgEGByuUGuC9TGYUewGb9
         XYpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l67sor1622160ywg.94.2019.03.21.06.43.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 06:43:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqw5PwOhd1NNd08+tnqkHFD93x8/dvdvJETQt4RzUQYDXMzJx9lmCJfqJW5NDLyJjwUYL9lIQA==
X-Received: by 2002:a81:2748:: with SMTP id n69mr3162674ywn.70.1553175820774;
        Thu, 21 Mar 2019 06:43:40 -0700 (PDT)
Received: from 42.do-not-panic.com (42.do-not-panic.com. [157.230.128.187])
        by smtp.gmail.com with ESMTPSA id v77sm3451008ywv.79.2019.03.21.06.43.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Mar 2019 06:43:39 -0700 (PDT)
Received: by 42.do-not-panic.com (sSMTP sendmail emulation); Thu, 21 Mar 2019 13:43:35 +0000
Date: Thu, 21 Mar 2019 13:43:35 +0000
From: Luis Chamberlain <mcgrof@kernel.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Xu <peterx@redhat.com>, linux-kernel@vger.kernel.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maxime Coquelin <maxime.coquelin@redhat.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 1/1] userfaultfd/sysctl: add
 vm.unprivileged_userfaultfd
Message-ID: <20190321134335.GB1146@42.do-not-panic.com>
References: <20190319030722.12441-1-peterx@redhat.com>
 <20190319030722.12441-2-peterx@redhat.com>
 <20190319110236.b6169d6b469a587a852c7e09@linux-foundation.org>
 <20190319182822.GK2727@work-vm>
 <20190320190112.GD23793@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320190112.GD23793@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:01:12PM -0400, Andrea Arcangeli wrote:
> but
> that would be better be achieved through SECCOMP and not globally.'.

That begs the question why not use seccomp for this? What if everyone
decided to add a knob for all syscalls to do the same? For the commit
log, why is it OK then to justify a knob for this syscall?

 Luis

