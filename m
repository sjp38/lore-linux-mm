Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7D8EC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 12:29:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F56D20657
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 12:29:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F56D20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1A608E0003; Tue, 12 Mar 2019 08:29:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC8F68E0002; Tue, 12 Mar 2019 08:29:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB8138E0003; Tue, 12 Mar 2019 08:29:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B41FD8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:29:40 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x63so2000645qka.5
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 05:29:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8rP1uKijqwMccEeY9+V9oz9TqrripK5ohh8qqdinygY=;
        b=BOvr7UkXdncQPexwYmgc5pOrZLBzvXS1ovEm8bTi9e2Uu2AgumWlpQGI3TWQ31EstE
         1FG/0jct0XIKupc1EcZMZz5ZVpeokwf65zicM7JYZHzHU3KEelEz/D859JdHUNaZXMQ8
         ESQqvXb5uCiGB6X3/rNIcB0LfvQZUnGS60l68co/ZzQr1uityyAhdUIao7lWOKVOutm0
         AGMpBmOnmnJP5APUMHMB2944cyXaUbRCRI/Tldtk5WU09dRcZ9k1eOiAgQnVdNLFhKS2
         qpj1QnorzljzinKqYsSvOgaMlq+YJwCVsgPfrZZG/05ILuPpF4+ajULMYIquQRbCSNl6
         TtsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVEYCYBRiRwEm03oBybo3EhButs07z8icegEXv0ftOnKo/he29+
	1gOtShZ9B1TBI1QAv8fesHs3A1/hKK47vB4vwNFu4aP1If+t7nrQsq0aVxQUCxQtruJdS6ajmqi
	mCUHE7r3m/gBALIA8f5Kkmien1idNitl8DfrQH2D8p25KHGNXMmaCsZenyTf3v6DZSg==
X-Received: by 2002:ad4:51c5:: with SMTP id p5mr30299681qvq.31.1552393780548;
        Tue, 12 Mar 2019 05:29:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPOsrcoRypr3QxsYWu6q4I/bgu8R6EDGJnZYXyrTSZql1k8WM+25ehj/p5JjemBR9Szezb
X-Received: by 2002:ad4:51c5:: with SMTP id p5mr30299646qvq.31.1552393779976;
        Tue, 12 Mar 2019 05:29:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552393779; cv=none;
        d=google.com; s=arc-20160816;
        b=R9SirltaHU1yt3lLk/JLhndQgRNFucAAZEkkjq+ZPGWqXIUqBnIzc9wzSx8kojQ8/V
         JdjRz9fejW9l/8E8OgkinoL7Cvb5U6o5GktrR9cPVe1Rx1/WnyalKaSqnqgNVEcl9gsq
         wGv3iOfWYDSzcZ7gTakww2AjNYliyEMb2lXYZvBtdFBdMYwqkQC7gNnBWVEhAYpYprRi
         xHlPLWBlOsUtiiw5+AJ0xJi2j3Q4Kj+AhAWa60xdMau5ZIAtv/HMNq6MQaEj0mJs0vtq
         fznt2ziGBn44RNpaCwm54s1Egef61aZkZXlGFxL6a0e0KXnOK/MEGL36iW/kww2ZKJj3
         Wq6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8rP1uKijqwMccEeY9+V9oz9TqrripK5ohh8qqdinygY=;
        b=QO2+OCdFF5b1jwn4t6rOMtMbE+yOeoJTTrBoxdrpmi1e5ReK8eaFc8A218zn+A5g3c
         dug3KNjS/kPoN0LZ1/5CVMdpauFXwQBQKRi0jLvp2tFUQikhIgAR/F7gp2hnMYs6poor
         m0IfrUiLNjcotj1OywfkDut0E91fsj8hU3dYdyr6OXe4DmnnE9e8g/GIhzvBNZKqKifI
         /fBoWHqJZO5/a/Apc5DG9632Tg1VwyM5SxVi/oVcl5HTugGd0fvCl1Oiakt+VfkBe4nK
         lPfzqd6rAo75I7k/uArUeh5u2M73whZ5jXTd7seIU0/UfbHwNmQdRR2sRmCs0g5Zj66r
         Lm8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s68si5166179qki.17.2019.03.12.05.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 05:29:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0C073307CDEA;
	Tue, 12 Mar 2019 12:29:39 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 230E01001E6A;
	Tue, 12 Mar 2019 12:29:29 +0000 (UTC)
Date: Tue, 12 Mar 2019 20:29:27 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
Message-ID: <20190312122927.GF14108@xz-x1>
References: <20190311093701.15734-1-peterx@redhat.com>
 <20190312070147.GC9497@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190312070147.GC9497@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 12 Mar 2019 12:29:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 09:01:47AM +0200, Mike Rapoport wrote:
> Hi Peter,
> 
> On Mon, Mar 11, 2019 at 05:36:58PM +0800, Peter Xu wrote:
> > Hi,
> > 
> > (The idea comes from Andrea, and following discussions with Mike and
> >  other people)
> > 
> > This patchset introduces a new sysctl flag to allow the admin to
> > forbid users from using userfaultfd:
> > 
> >   $ cat /proc/sys/vm/unprivileged_userfaultfd
> >   [disabled] enabled kvm
> > 
> >   - When set to "disabled", all unprivileged users are forbidden to
> >     use userfaultfd syscalls.
> > 
> >   - When set to "enabled", all users are allowed to use userfaultfd
> >     syscalls.
> > 
> >   - When set to "kvm", all unprivileged users are forbidden to use the
> >     userfaultfd syscalls, except the user who has permission to open
> >     /dev/kvm.
> > 
> > This new flag can add one more layer of security to reduce the attack
> > surface of the kernel by abusing userfaultfd.  Here we grant the
> > thread userfaultfd permission by checking against CAP_SYS_PTRACE
> > capability.  By default, the value is "disabled" which is the most
> > strict policy.  Distributions can have their own perferred value.
> > 
> > The "kvm" entry is a bit special here only to make sure that existing
> > users like QEMU/KVM won't break by this newly introduced flag.  What
> > we need to do is simply set the "unprivileged_userfaultfd" flag to
> > "kvm" here to automatically grant userfaultfd permission for processes
> > like QEMU/KVM without extra code to tweak these flags in the admin
> > code.
> > 
> > Patch 1:  The interface patch to introduce the flag
> > 
> > Patch 2:  The KVM related changes to detect opening of /dev/kvm
> > 
> > Patch 3:  Apply the flag to userfaultfd syscalls
>  
> I'd appreciate to see "Patch 4: documentation update" ;-)
> It'd be also great to update the man pages after this is merged.

Oops, sorry!  I should have remembered that.

> 
> Except for the comment to patch 1, feel free to add
> 
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

Thanks Mike!  I'll take it for 2/3 until I got confirmation from you
on patch 1.

Regards,

-- 
Peter Xu

