Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5E22C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:46:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 947AF206BA
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:46:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="ZWOn1Mc/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 947AF206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 369F06B000A; Thu,  4 Apr 2019 11:46:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F2B86B000C; Thu,  4 Apr 2019 11:46:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BBC16B000D; Thu,  4 Apr 2019 11:46:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9E746B000A
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 11:46:32 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id d49so2620398qtk.8
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 08:46:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=M0bXkAwyWwZez/CeyEaHWJvj8pkym5UfuurSaaeC5+0=;
        b=VU7ppjkVGyye+Ks+a5Lqw3dwAB0E67GyKUTa3bSrBGwo9uOIGkBUCQQr+y3KOh/Qvx
         jMzJYq0Rt5AIzxgPkHbQR9I0F7GHobNKoRDkjGthXitfGlrBnqvhDsoMOGv5BebnCy4I
         ujXzH3YCznoETRktvz0VEaFhnHtyLTh9IKX/fhVRDe2+txZcPSdzuF8QckwAumbGPkva
         qFcJOs0QEfmsircgRikeiXWNaplIT213XSJl5HD2Dqog8po50KwglDhmzVNuhuSrjcBm
         04zQ++e9iTIZ6nPYhpJWXaOzyBWYcCUoeV64z2zGR+UiB1r4jYzqtNYyn9kP3ntcAqo7
         Fb9A==
X-Gm-Message-State: APjAAAWZOkF6nJctXuLVFOXAKZP7Rcu5tyf6h4wGIo9F+ZFsNTs6vmY0
	Z1eqrOeDbDpUJ9i6rcU4yI035+0fIsk6pLPSPuaGc0cqS6z1BoZFjmDtgY2m3YyEEX2T0mF8Y+l
	KUX87VYHlTJlJmiHqiJenq34sCNlogkMycu7P+m/xRkcVNkhcckiDlRViO78//cM=
X-Received: by 2002:ac8:91b:: with SMTP id t27mr5899235qth.107.1554392792601;
        Thu, 04 Apr 2019 08:46:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwY6jqbB7twLe6+dbyQLYGnBmCAj24J7BQpbmmDg/dfxyMstZo9T4dCcURSvJhYRE8zdFT4
X-Received: by 2002:ac8:91b:: with SMTP id t27mr5899190qth.107.1554392792037;
        Thu, 04 Apr 2019 08:46:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554392792; cv=none;
        d=google.com; s=arc-20160816;
        b=vrZe8hH8sQV2nYI1tSG9shJyEjyrEqZXUKBTtSw7sAdbNiKGcvY2k8lulk5Y1e3Z1/
         WhdBNpwRHdCib0kMZi7VUQtEPY35BWXX7aTLGazTwWzWMNQhEMoQMx0RU/Pk65DxVwLW
         jzcok1bMlJ4sETufI4kACan5C/X2pyCf8qS9pOiStLetHZ8B0cmI5PjibpANlt8paCOe
         AyrMgQCpMilwdCei2BVAevdMfXyUDZpgtxlDas7LMV6gUD8KV/QL/2Hl5pG9a7ki4s09
         zUvtq21iH1DRcl4FUMQ3wv/8qsAXQ4KILQUa5CCsX/uDIt2W9uY95wAohZTZZDdKBqWf
         5U7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=M0bXkAwyWwZez/CeyEaHWJvj8pkym5UfuurSaaeC5+0=;
        b=vAWNahhgkWoGQ1UMqo0NeMx1OMeXaxGDVnO3eviqyZwO7DyZ6klOH1D4xdyMQfNl63
         U0jVPDNKWnZRp0g6p+hcvHWncD/zVTBO7PJMLoafS4DODkIr4f5TFWfMpcF0RavNIf8U
         hbaGcAFsiRsZhhwCkWIFplINNbrVC0eZtdvU5jCtm9oQ9aO811eod/3d5WSCHNiMl1HC
         oxZ1x0WguTG4ULtfK2gZAw6uGzEEiLboiBnKKgrazb2yRprH0SSHaaovGwtHHWY55Tfs
         5XgnrE5swB5clxpGZMmCwCamcdKENOnZ1itY84LOBdKqLJjn0x36xS/ygEHGuMRlpabo
         /HWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b="ZWOn1Mc/";
       spf=pass (google.com: domain of 01000169e907b8a0-2dbaab3f-18ad-4744-a81a-78809e2b7756-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000169e907b8a0-2dbaab3f-18ad-4744-a81a-78809e2b7756-000000@amazonses.com
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id b11si102161qvo.145.2019.04.04.08.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Apr 2019 08:46:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169e907b8a0-2dbaab3f-18ad-4744-a81a-78809e2b7756-000000@amazonses.com designates 54.240.9.35 as permitted sender) client-ip=54.240.9.35;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b="ZWOn1Mc/";
       spf=pass (google.com: domain of 01000169e907b8a0-2dbaab3f-18ad-4744-a81a-78809e2b7756-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000169e907b8a0-2dbaab3f-18ad-4744-a81a-78809e2b7756-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554392791;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=X/2BCjBLOwDcCBYuqS+EKFW7PX1QL8vk7+x2K01CwMI=;
	b=ZWOn1Mc/6/Z6wYKOt+kb2vZGIZ2iEyJ6G8RhqF5UjGurHdo7LenW790CvTeKwXqp
	ffbQj3A2xpA88fJD8sVpYGoZRwnuJvSLw6hh3FnOb9nIEY9WKY74uZrvxvIzQGkwFu6
	drKobnYvkMnqw2qFeDTht5FgRvoE0Us5o+pBRNvA=
Date: Thu, 4 Apr 2019 15:46:31 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Al Viro <viro@zeniv.linux.org.uk>
cc: "Tobin C. Harding" <tobin@kernel.org>, 
    Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
    Alexander Viro <viro@ftp.linux.org.uk>, 
    Christoph Hellwig <hch@infradead.org>, 
    Pekka Enberg <penberg@cs.helsinki.fi>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Matthew Wilcox <willy@infradead.org>, Miklos Szeredi <mszeredi@redhat.com>, 
    Andreas Dilger <adilger@dilger.ca>, Waiman Long <longman@redhat.com>, 
    Tycho Andersen <tycho@tycho.ws>, Theodore Ts'o <tytso@mit.edu>, 
    Andi Kleen <ak@linux.intel.com>, David Chinner <david@fromorbit.com>, 
    Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>, 
    Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, 
    linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
    Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH v2 14/14] dcache: Implement object migration
In-Reply-To: <20190403182454.GU2217@ZenIV.linux.org.uk>
Message-ID: <01000169e907b8a0-2dbaab3f-18ad-4744-a81a-78809e2b7756-000000@email.amazonses.com>
References: <20190403042127.18755-1-tobin@kernel.org> <20190403042127.18755-15-tobin@kernel.org> <20190403170811.GR2217@ZenIV.linux.org.uk> <01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@email.amazonses.com>
 <20190403182454.GU2217@ZenIV.linux.org.uk>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.04-54.240.9.35
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Apr 2019, Al Viro wrote:

> > This is an RFC and we want to know how to do this right.
>
> If by "how to do it right" you mean "expedit kicking out something with
> non-zero refcount" - there's no way to do that.  Nothing even remotely
> sane.

Sure we know that.

> If you mean "kick out everything in this page with zero refcount" - that
> can be done (see further in the thread).

Ok that would already be progress. If we can use this to liberate some
slab pages with just a few dentry object then it may be worthwhile.

> Look, dentries and inodes are really, really not relocatable.  If they
> can be evicted by memory pressure - sure, we can do that for a given
> set (e.g. "everything in that page").  But that's it - if memory
> pressure would _not_ get rid of that one, there's nothing to be done.
> Again, all VM can do is to simulate shrinker hitting hard on given
> bunch (rather than buggering the entire cache).  If filesystem (or
> something in VFS) says "it's busy", it bloody well _is_ busy and
> won't be going away until it ceases to be such.

Right. Thats why the patch attempted to check for these things to avoid
touching such objects.

