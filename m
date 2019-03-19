Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D234C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:02:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46C2C206B7
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:02:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46C2C206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA0D56B0007; Tue, 19 Mar 2019 14:02:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D29236B0008; Tue, 19 Mar 2019 14:02:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC9476B000A; Tue, 19 Mar 2019 14:02:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB186B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:02:39 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f10so22993506pgp.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:02:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j7wBLdCJbTzs+6Fxd25WFaoQuqboFDKMyoI6KG3bXjY=;
        b=TajQ+h6X8kgVsnEfoQPTR9OnszO0I1Ldl71XSsMj9ZXUvrMU2PjQmvlXSVSinnGAkR
         lGjCnTsmp02TyYGfGuWaBSt0mLkfyt0i72N/4vAiHomQS70gs/IQcXKH/8lcjFzbCGh2
         w9OL3n8LBVIojMmuDMZcnw8ThFrBvpyTWKI6ZNMlPyFZ/SwETdVenoI89ijlBknMTRcL
         +daw+nOZwV7Z7hSfWkWO5pajWIzZSM1bQb7hUj8y1AkiEx8KC/Q7cHw58YGiimDqA1uT
         JGnwTGDA+Xej6Dip2nOuyscRkOJrxgK28YFiLUOKGbsnzO1gYcEvtHxJ8+A1BIYXXoMU
         mKcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXvZ1DHS3MppKHUwEN5uPBzuNneXA8EQ11Cw2vnsuVaRivulRhG
	WmHdgg6dkDlDz/MB+EHpdK1TlHrJxD2JyJwNdtAU6fvR970gzhe67H4GCnPtVADlEu7j2wQCRLT
	PvnItp4jt6mSa3tenoYbSKKDYyWuDuHiQlgnOlzIq87mQTmOMCeh/oKTfy5mjJ/eeFg==
X-Received: by 2002:a63:e813:: with SMTP id s19mr2947688pgh.12.1553018559134;
        Tue, 19 Mar 2019 11:02:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMJnpPSWH81LtIN43XUb6Xrrul01m50TSuR3Gyno/gnkvse4YzdBkWpwjAMs9f6wFxmJVu
X-Received: by 2002:a63:e813:: with SMTP id s19mr2947624pgh.12.1553018558286;
        Tue, 19 Mar 2019 11:02:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553018558; cv=none;
        d=google.com; s=arc-20160816;
        b=GsUpvDSvnqcg7vG59X+kClipYruKOfoGidFbtL39aNF2VBfgPU/pzcv+2q2thDhicD
         f/n1BJqdM9QsmWNXvI44LxZ5oF5VWPcdzqcV8/FHrBXsZLb6AueQpNrPYqctQ5dUumNj
         ev7qab1abnorUnTO0LRf70O1tB4zgRBW8sGLfddr3jLFIfgRBdiq/CmgKqgPQyLWQqgy
         jaAJYZk6OY4gr7AFrhDm14NcHCUdPGWTr9CxpqU5qjEGxsE2XnW0NsQH16SZDNU3cptN
         86FBojmn8iY3k4FBcpgobOUBFP/i0LryRdk4vtSj2+p5czr+/bXzL7LB1DGpcUnjJ6ZH
         uxVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=j7wBLdCJbTzs+6Fxd25WFaoQuqboFDKMyoI6KG3bXjY=;
        b=ZRIKl1/2xkMvEK9yOv+b/miXCpiTelwizvxV58liHIMPoMdGXywfWQvKnr7DXCm88e
         6Di5Fr+MMzG/YdQNQRfYbctF2lWhwmFP2Cg8xNSpCsIIMGpfBhGGnifp7paW4gkWxUX1
         ZwhqUtIoXDOvVWgF5MSW8GueIFkIvFuh266xd1p+9a2M6gRwvHVIO5Q4y5xOrux+XsQD
         N2xC5f0pptoUIvBrUDnxTWURrW48oQk+onU7xFnzVbuTD4LzeOfGC1kpbAW2imhcuE+9
         btaZz0WI0q8/mCBuh486Hbw3yfas+pkYKZOMWOU97J7uXqXCW7vZc6rj+rrQeZ7ymyaA
         O9DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v34si12624571plg.176.2019.03.19.11.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 11:02:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 3CA3F3802;
	Tue, 19 Mar 2019 18:02:37 +0000 (UTC)
Date: Tue, 19 Mar 2019 11:02:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Hugh
 Dickins <hughd@google.com>, Luis Chamberlain <mcgrof@kernel.org>, Maxime
 Coquelin <maxime.coquelin@redhat.com>, Maya Gokhale <gokhale2@llnl.gov>,
 Jerome Glisse <jglisse@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>,
 Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org, Marty
 McFadden <mcfadden8@llnl.gov>, Mike Kravetz <mike.kravetz@oracle.com>,
 Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Mel Gorman
 <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>,
 linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 1/1] userfaultfd/sysctl: add
 vm.unprivileged_userfaultfd
Message-Id: <20190319110236.b6169d6b469a587a852c7e09@linux-foundation.org>
In-Reply-To: <20190319030722.12441-2-peterx@redhat.com>
References: <20190319030722.12441-1-peterx@redhat.com>
	<20190319030722.12441-2-peterx@redhat.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Mar 2019 11:07:22 +0800 Peter Xu <peterx@redhat.com> wrote:

> Add a global sysctl knob "vm.unprivileged_userfaultfd" to control
> whether userfaultfd is allowed by unprivileged users.  When this is
> set to zero, only privileged users (root user, or users with the
> CAP_SYS_PTRACE capability) will be able to use the userfaultfd
> syscalls.

Please send along a full description of why you believe Linux needs
this feature, for me to add to the changelog.  What is the benefit to
our users?  How will it be used?

etcetera.  As it was presented I'm seeing no justification for adding
the patch!

