Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87715C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:50:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BF952083D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:50:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="bOC62TCM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BF952083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE4B36B0006; Fri, 22 Mar 2019 13:50:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E93E96B0007; Fri, 22 Mar 2019 13:50:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D85CC6B0008; Fri, 22 Mar 2019 13:50:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id BAE926B0006
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:50:21 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f89so3061813qtb.4
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:50:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=iIgmAU/fmwNi3T/2GQAeg5SnVOfELTKSk9Yud2RNxkA=;
        b=quI3/U45LbkvjnlDrMjcAQ0VWORN4uZ2RGttJOBQWU2AkwL8a/9euA9P+hkuQEGrG5
         3TgSwz80HlWDApPa28F3PfeaB3aIYsYs7Jw57eAr8zsB5Q4OgLg4qR1LAVFq9h3q78Gq
         WSPWwr39HvBdpqN0THvl6I1nNsTRjxa4mRPpiDCJTP+uthg2WGPj+Wy3x6ejWyn1Edvq
         U8T37wLk+VWT/lGtjEf/YQUrZD7m42FnsSglp/BTe7XzyI4oEiYLWoN7G1LGHJi3zHyR
         7bxEpnyIgICt2eHb9sm1ZbIfd2UyXFZOL8w82P71C+XVeJjeDGu12H0MP4oJSBVZunTJ
         Wdlg==
X-Gm-Message-State: APjAAAVUt52ZdLiEKKoqXAksELCYMtuQCj6e7RqxWzjiN1RhIIQbq94V
	+vl9h/uD/i0irf1QEZvDa3S1dPeO5C4rsKd4dlbx6UnfxkqpU5h9MdKWAZFXp7BjY0/I/YnPKpx
	gGZujAUeuqMGjVgki3foFf6QR9uR6Vtp8i17r7qKnEPfjlMmC/kHDAt1s0BcPjdg=
X-Received: by 2002:a0c:b78e:: with SMTP id l14mr9271136qve.129.1553277021571;
        Fri, 22 Mar 2019 10:50:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJaAODyr8zFJqt0cBvkLIjNk1mZ/Puebd4q6MiN8oSvJUCdqhHzPtBMwUumjZrQ9hfMVL1
X-Received: by 2002:a0c:b78e:: with SMTP id l14mr9271091qve.129.1553277021020;
        Fri, 22 Mar 2019 10:50:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553277021; cv=none;
        d=google.com; s=arc-20160816;
        b=S07iHsWlglYSaZTR+8QGx7yw8ivNSbA82KjCae4LknzAD6GOls/iT8xIOpMW8A3ijj
         uJZS8xmwDnKWgIdzQzir/+B2+xYzv1Z7bbGQDdta2Q3n01n9ae/TImEc/F9j458T/2Qu
         lIDekJkRVXeVLhePJ2l1O1QVxbo12aRHQjcQ5ETnyi/Vv6apXu87xTGp5fymxWiPQf2Y
         b0xFDomXa1+XhKfPsm+hBDVCfgyrSZngZM2i90taj/2uYFdNZGMDIQ4oAh3uNVzFopIE
         wjm3kCWm/Cz1wvrqccpEv41l8AZkvWTysClhlGHK7FZOh3gx2eOdAOJEyzoyQBLjrVCD
         pzvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=iIgmAU/fmwNi3T/2GQAeg5SnVOfELTKSk9Yud2RNxkA=;
        b=c2T4UzaiEHCmU/OBPu4v3/0zfM7T8yKupnZU20f1Q5122Zd+VmsOIedu47HUKG7brw
         uM/I1abOJkPzwcC9ApoH5dpitXvOLNeaKxSqJxGNY/WbgCWjbxgvBzSyuznaQDIFjE0d
         DZxNqPVSVcBxZb7ZUqZXd2qfD3Lz/jK0oI8LjJbucfjqyiio04Dg9kTjAD/15gdriOcd
         TjEP7nhqJBfMqxT8Tl/YYIE3WaTbtrhPFLq6rszs2di8OAP7oOKvfI6AHyumHZwr2ajY
         01lfx7sqv8mJdlbnwcOZOPvsXvzrdcPXv0lPcR/aC/evAclg3CfqWD2O0+5GFatK+kkh
         HcSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=bOC62TCM;
       spf=pass (google.com: domain of 01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@amazonses.com
Received: from a9-32.smtp-out.amazonses.com (a9-32.smtp-out.amazonses.com. [54.240.9.32])
        by mx.google.com with ESMTPS id h1si130083qta.377.2019.03.22.10.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Mar 2019 10:50:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@amazonses.com designates 54.240.9.32 as permitted sender) client-ip=54.240.9.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=bOC62TCM;
       spf=pass (google.com: domain of 01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553277020;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=iIgmAU/fmwNi3T/2GQAeg5SnVOfELTKSk9Yud2RNxkA=;
	b=bOC62TCM7G6uxAcMzaA+xU+tnbuSdATCmTtXQo6j8wnQxuRyiSrmNIhyUKo9JFTY
	SlFgTxD26wFebqplJoWTJBWgdn7/NN/ihuQsM3VsuSdOiZK3UA2D2b75/n0QWbExOut
	IbCYs+QHKy29Mvnk1COekXG0qSFVOAJCSoPueu6w=
Date: Fri, 22 Mar 2019 17:50:20 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Waiman Long <longman@redhat.com>
cc: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, selinux@vger.kernel.org, 
    Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, 
    Eric Paris <eparis@parisplace.org>, 
    "Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
In-Reply-To: <d9e02cc4-3162-57b0-7924-9642aecb8f49@redhat.com>
Message-ID: <01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@email.amazonses.com>
References: <20190321214512.11524-1-longman@redhat.com> <20190321214512.11524-3-longman@redhat.com> <20190322015208.GD19508@bombadil.infradead.org> <20190322111642.GA28876@redhat.com> <d9e02cc4-3162-57b0-7924-9642aecb8f49@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.22-54.240.9.32
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Mar 2019, Waiman Long wrote:

> I am looking forward to it.

There is also alrady rcu being used in these paths. kfree_rcu() would not
be enough? It is an estalished mechanism that is mature and well
understood.

