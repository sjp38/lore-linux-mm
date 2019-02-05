Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C390C282CC
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 19:03:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3E462175B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 19:03:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vW6cIpa4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3E462175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E8088E0091; Tue,  5 Feb 2019 14:03:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8971E8E001C; Tue,  5 Feb 2019 14:03:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 760638E0091; Tue,  5 Feb 2019 14:03:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3436B8E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 14:03:05 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id l76so3280317pfg.1
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 11:03:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=U4R4yE369nrKTa7CgvPCPtgPOR1uNAIMOfUGDkxSCgE=;
        b=jBuO8pF4Y1w2Knodin1I69+E0dFDCz/tvkverXjxcNzKv6wEq1OZI+QbRI6xvAOjgw
         Fsy/fApPMZJv7B6i69XiQ3tlUPGLT248v/NLYp/V17RrnvoFWmWZcKnvhNPfTOkeMu3c
         TEEENceJn+OdjJzaSJ4OkT5pgHhoXnUo3r2pR7T1JljyvQL6exvSy9dkdbUp/UihWl1k
         edfF4PM+rSYxXHI4I8Gdfxu4ojZpRma+bVGMHuXEwpmq/VUj/hYaIiVp1nKX7ITRiW68
         +3QC8rs6xG1ivdouqFJDZDHH/0ffGfdXwqEG3fPxQTrhNU8lQp5BhA8LvfE6fjERcxTV
         id/A==
X-Gm-Message-State: AHQUAubLnjVM7GAwTmJ1fX79BNmC+0y2xYv7yuFP0KPS/HL8qEpEdqDK
	QNeEz7i/0dgSeDA8us5Rkg11JOdfHmHbZq9gbxaF+2FQ+1O5w4Gv0K6NwpEE7FXPnlZM31p4tRW
	Ou9vy31B/b29O/2Ty0lkNCtKHU3Fh2foZ9hV39JVFLLAOipg9dhEfwCBoWkjkkhYzdeO3H+9Z3N
	vjrvGUKs2CHm243HA0O5dnX9UDqtWv6Vo4NgLBW84THfKyHPJGrP6YD1TTNzfArp6mzBeYXm+Ch
	MGSfeKXndEqg6NFR0O45NkWJ0bhoG4MShc+Ug6qUMX1hJf7j6PtssEnb5K8bCGUVbXcuUi+HbVP
	hrATfdgjoqsI1FQxveoTVtNpkU0x21YYTobGczm2QevWXIGHoBxABpEcIMpyLxbvpca29W5hvX2
	a
X-Received: by 2002:a62:3006:: with SMTP id w6mr6516428pfw.258.1549393384822;
        Tue, 05 Feb 2019 11:03:04 -0800 (PST)
X-Received: by 2002:a62:3006:: with SMTP id w6mr6516332pfw.258.1549393383823;
        Tue, 05 Feb 2019 11:03:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549393383; cv=none;
        d=google.com; s=arc-20160816;
        b=Ed0oNBIlt6kMtmfirt/RV28zNq2sqzYTZye/ojDI3EbiF10CzkAqYiUSYyP6FSQgqM
         zp1hXaRAChPOxA6RKlXZ0iQ+gBAsyFolEIGNuPMAJAkzAgVaMZ/3dL+L8jcMBXwuY7gs
         7BYGD3idHbEPJgjRi65aQx9cOI1SucDOpKPoMMc4i9tZMIHgP59fIR5uurRGH0H2w6/L
         thjO0BTwK7StHKJBZSGxYVes3dcwlMCq3WZJJ+Wm+zjUk5jtyGdlj/2/OQVP1jfSLhkF
         eXmU+krHaWkH+jLhG51EMl5Lw0vrc59OQLGH03Lxju7K9tF06fRFBcTf0RSl+cITlYza
         DpLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=U4R4yE369nrKTa7CgvPCPtgPOR1uNAIMOfUGDkxSCgE=;
        b=iPx7v7nFZv2TfRUTTaH9iF2ZKnGyJ0LGovOT+cVELmTuMv2laLfNPGHYe2/iD8ATWn
         tv0frXcj2aSz4kCtjVMjnwD7JYA/0S5M8vP4SCBPmzLxaCCVfSWS0H115YH4CBq5x4JH
         Pqu9bJM5BflKcriE4pYaW+fjk6ZjRXRnZhpboDMa9BEendKX+bgAA5bFAS27awwn3KLF
         58lgGknAu4jo7RxHYnLChLOAkfPeTlVVfXPZv/iNM5HuxqIplesellnxVcZ3OAQMsSVS
         xaSS6XVhdVJJA8+FsneXWJgA1onfD4bdHPBqTEr+Uk/j9okul77/jOteyXC7V5esQynJ
         GLkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vW6cIpa4;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l71sor6464091pfi.24.2019.02.05.11.03.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 11:03:03 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vW6cIpa4;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=U4R4yE369nrKTa7CgvPCPtgPOR1uNAIMOfUGDkxSCgE=;
        b=vW6cIpa4Ip2dQnvO55zgU/BZbaTziP0rn3LBpSGLPaUiUlZ8baDnFw1yxbnf4trxH3
         psWLBB/q7sqsxGnFJOtNSWlX5g7Ez0ADxEwc+tkWyBqpZK63WDoxpSxBV+hORg8kzW4J
         ULH4CQLYVbe0/mR5x7NbtmY2WmHxT7f/UlsRDwM8ajkWC1oY2pWoyaU4xMihnG5XKiwz
         2I7cdcHf1vGHDTVKaS3+WB1S9Ew8dqzFlX3tZEvTlFnQMq1bKSviRrViAjxrFR6Vqp6M
         6RJH+COyJmzszurQTRP2fanOIP/T59KoSyCYfuQxSUQByPT08WhZKamvZmf6a9GVIQ6t
         8a5A==
X-Google-Smtp-Source: AHgI3IYigtc/NZJ+hOsqBz2l+YWFFJmz3FXNhOyzEH5zFomALCTTclGAU03PtrJ9Mw2JgNfv6KxM+g==
X-Received: by 2002:aa7:83c6:: with SMTP id j6mr6427291pfn.91.1549393382267;
        Tue, 05 Feb 2019 11:03:02 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id z10sm5194066pfg.120.2019.02.05.11.03.01
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Feb 2019 11:03:01 -0800 (PST)
Date: Tue, 5 Feb 2019 11:02:49 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Qian Cai <cai@lca.pw>
cc: Hugh Dickins <hughd@google.com>, Artem Savkov <asavkov@redhat.com>, 
    Baoquan He <bhe@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, 
    Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: mm: race in put_and_wait_on_page_locked()
In-Reply-To: <1ce33d5f-1f0f-7144-2455-fbae7f5f82c8@lca.pw>
Message-ID: <alpine.LSU.2.11.1902051101340.9007@eggly.anvils>
References: <20190204091300.GB13536@shodan.usersys.redhat.com> <alpine.LSU.2.11.1902041201280.4441@eggly.anvils> <20190205121002.GA32424@shodan.usersys.redhat.com> <alpine.LSU.2.11.1902050725010.8467@eggly.anvils>
 <1ce33d5f-1f0f-7144-2455-fbae7f5f82c8@lca.pw>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2019, Qian Cai wrote:
> 
> >> Cai, can you please check if you can reproduce this issue in your
> >> environment with 5.0-rc5?
> > 
> > Yes, please do - practical confirmation more convincing than my certainty.
> 
> Indeed, I am no longer be able to reproduce this anymore.

Great, thanks.  I'll add a message to the other thread to wrap that up too.

Hugh

