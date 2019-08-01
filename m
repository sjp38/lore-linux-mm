Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C003C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 04:21:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFEA6206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 04:21:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFEA6206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58C978E0003; Thu,  1 Aug 2019 00:21:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 515DF8E0001; Thu,  1 Aug 2019 00:21:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DDE98E0003; Thu,  1 Aug 2019 00:21:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 145648E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 00:21:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i27so44826554pfk.12
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 21:21:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mxjVhZTF9bQ7TdK0WidNhoxg+QgR00eGaPdEGMcXCNM=;
        b=aWVg3RR5UlByW4mexTeLd1XjEx+CWgEOrdb7fsEWfIUAQpAnfc8b9ZeyjpKc8fD7uv
         ZMWjNsKHHYHBKwVrj03NpWXJvA7BkveNxyJxE/ewtYH8HbXIRLFyTwxwT4ZO/kYyXYCc
         G53wrLGyzR/P2csb1MCNpE0fWuKGJkmLrt+DjRdDsHf0F48llei1DF1QIRwsQc7TyPpf
         +hxpXIm9mxjbLUMilEyog1S6oJdrVh8OH4O5smaBQ8SzVZRPaaPmuAezZ1CnGHNFqycO
         392atkD1HAINk2pX+OVpm/5aTUyHcv5XarGR6x1iRjo83GLoYMeuMjSuQDa1ewHiaYRt
         hE4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVFHKlA2cZSe+wJrtoU4Bgyu/c58Bhh4x+svV4dXAhn0XjDzrt6
	SXJzu5PsAeZjcPuBR7yT6xEucaWaqs27gsVfaFUKmuBvoc9awUeELd+cjaaLRGOkVs0y0LxT/SI
	D6ILskYQ+9YZI50lpH/Qqccj+TI7TYlWS/7w3TxEOZqtHrFdFaLG3Zo0qjwfW1dAlLA==
X-Received: by 2002:a17:90a:26a1:: with SMTP id m30mr6506283pje.59.1564633260726;
        Wed, 31 Jul 2019 21:21:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYHofqMLAABxXCeJ8RneiHY8TFE1oPfy/Zft/IUEjCY54VIqa10cfxY/DvrteBUE2xtT/x
X-Received: by 2002:a17:90a:26a1:: with SMTP id m30mr6506251pje.59.1564633260034;
        Wed, 31 Jul 2019 21:21:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564633260; cv=none;
        d=google.com; s=arc-20160816;
        b=kt1/VsyQwZU7yFs1BNQfcMkN1Nu6qJV2yUZ+IOqJtg4fnJ7PghqoG8qOutkBaUGtaV
         d4h74YxBBG5IoKuVk9bRQkMZVjO2qyThOl6mTWwyAz4cmb5FRe9PzR0E3ssycQclUtsD
         1ueSGvVrikE3yq63y18WflpSpKSV5RU/GulHNEtNW6aFSyENs/Cz3xils5lCii2NuC6R
         v9TDARa71g1h1/+FEAwWivgv8+jHO34WuSCNDIugBhazCXW2LbhEKlHZ46IuT37X39nx
         gUk67ZAx7xjCJ7+97dnNKgV3j/PtQKYht9fTcPllz0LxbAvOTVxk5OtB8zJiA2xqI6d7
         nAGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=mxjVhZTF9bQ7TdK0WidNhoxg+QgR00eGaPdEGMcXCNM=;
        b=bhz+Ecz+ru1i0f0PfJIaQNKj+pwctPLW6xPPvLwK7JxZ09+FqtJkZXVbT9ZshbSNDU
         0WsPAlSoBF/JUvAGLc7viox7L3jlJVPj5GmabLMo6dEgkmFvL/ubJkjcA5f1QvuXEZ4h
         copmXXgVdDBR/Pf5BM8vLjkYmG0D//DgNp4q6F2HdgkCOLxrYjQ8H2nxjgsx30hLuxi2
         uBX8B01W7gR7w+45ijk2TTM/TbGEwII/uLAfcuwcNKKlqe1jRaqg6r/jSOWJ01YuWm22
         1N6xjbtWPl/x+zr2AypOekDExXosBndT4OCwgPFtWbEI0bTx7mnvWnDGd6sH/9fb4MPC
         gqDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o19si34360825pgj.120.2019.07.31.21.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 21:21:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (unknown [76.191.170.112])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 3B9324379;
	Thu,  1 Aug 2019 04:20:56 +0000 (UTC)
Date: Wed, 31 Jul 2019 21:20:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com,
 Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] fork: Improve error message for corrupted page tables
Message-Id: <20190731212052.5c262ad084cbd6cf475df005@linux-foundation.org>
In-Reply-To: <a05920e5994fb74af480255471a6c3f090f29b27.camel@intel.com>
References: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
	<20190731152753.b17d9c4418f4bf6815a27ad8@linux-foundation.org>
	<a05920e5994fb74af480255471a6c3f090f29b27.camel@intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2019 15:36:49 -0700 Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com> wrote:

> > > +static const char * const resident_page_types[NR_MM_COUNTERS] = {
> > > +	"MM_FILEPAGES",
> > > +	"MM_ANONPAGES",
> > > +	"MM_SWAPENTS",
> > > +	"MM_SHMEMPAGES",
> > > +};
> > 
> > But please let's not put this in a header file.  We're asking the
> > compiler to put a copy of all of this into every compilation unit which
> > includes the header.  Presumably the compiler is smart enough not to
> > do that, but it's not good practice.
> 
> Thanks for the explanation. Makes sense to me.
> 
> Just wanted to check before sending V2,
> Is it OK if I add this to kernel/fork.c? or do you have something else in
> mind?

I was thinking somewhere like mm/util.c so the array could be used by
other code.  But it seems there is no such code.  Perhaps it's best to
just leave fork.c as it is now.


