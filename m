Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D559BC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 15:16:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F46020989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 15:16:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F46020989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D3648E0004; Wed, 30 Jan 2019 10:16:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25AD48E0001; Wed, 30 Jan 2019 10:16:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 124CB8E0004; Wed, 30 Jan 2019 10:16:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7CC28E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:16:00 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so9340043edt.23
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:16:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=gyb5ViqkzGKWKm4NOTLdGUR8XoaOA4hS18kma3ZyTMs=;
        b=Qg0l1IHHQr9sy4v+rz05Roj4r7Rr+DcUD2DrUvN5pn4utvrnrkG6afO5yi8DryXSVd
         4focKpjmDBaGEd9cCd5EhVeq0COeYf1UoIqR7C4g5EMSOa+TN7MSYoMl/5P82ZQ7DIqM
         O1NYolts8B20InBEjxvx0M7e++wMs5b+hmjckz334XqLIkCn6eOYvSmCCchU/jg4W+xI
         mUu9uFn+cEsQxzGW+cXU3fXXdSrTnXWNRQSu0/u0PejDDnKv1uzke7gAAitQOCsKyaf7
         ngFBzBW2dZVjmMkYywSy4FgG5v8aFsl8+Ws7QHLb34vUzwgVJyhU2dl8YQOfZsgCr3sB
         sJDQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAua/5ubsWokFNyDBFiYgL7L8Gcz+cr6JH/usvnGYZRkqUiERtKg+
	gSjx2pDayU7YN3fXMl2iv3ZoJapRZQwaAJ7xdHTY9HUAY9i7qXq2uIMCHVvFnIzm6gc5TCAy8y7
	lya2cYon+p8CLLeor7DISzrMuLsELA0uyUBURgFzYEYfUiOM0HqxCZj9ZyZCdL5s=
X-Received: by 2002:a17:906:9493:: with SMTP id t19mr2341838ejx.63.1548861360159;
        Wed, 30 Jan 2019 07:16:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbVzw5ClgEVagTgqoxamEGCEPRcOkGEjXzxRVINBAMQH7sfcY9Y/tDiop/uFjceKOE7S9Fn
X-Received: by 2002:a17:906:9493:: with SMTP id t19mr2341793ejx.63.1548861359269;
        Wed, 30 Jan 2019 07:15:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548861359; cv=none;
        d=google.com; s=arc-20160816;
        b=YQNYVNDgYDqq6BZsr7TkGKGAattujlF+3Fz84vr9kNI2J6nNMAqA4RbsTJM/Pq6apA
         SwJW0+K9b6Yow2G/lpjjzDGCGgL4vG8ewMyP6JqpSAKdh8elJaoqsG62UHshsgiocpGh
         Sd5YVJRgHDtW9z7W1u1561RleHsRgYmdBcXgtvx5HoMJum8lS0iggYanT+tpiOUoXyfJ
         F5feeX7t/q2OF2Z6xchE6lebX1Ln+SQc4L2qkvhJ8swYbfTMbq2VCGj8Y92HqTTv7qDY
         kqVv7yWXu0OqaNVHPzzpYfaK0utqDYI4keggfX1edkfDVexJgDipNMJglXQe/SsUxM66
         9QhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=gyb5ViqkzGKWKm4NOTLdGUR8XoaOA4hS18kma3ZyTMs=;
        b=jv1mpSDNWKV9moOfitHTKPyxXDsk3ppTcnFzZWw0/hxXR6H7IGTX0uSETSKxH3ggnp
         9ESFpzkKeVI5LLfus8JqBbaTsYZkjXSnz4fWAlrY5hFsedzePkdjBjBxaWQsgOw5OojL
         umhmOdMtcMp6FcGCekv7cHVoKb+gmyoKuQlGoi9bi08xx1Mjk79m+oTXwLPsRtpJWcHA
         paAeoQqcNJNb/wXna8Uq205FaX+bklnHn8fKqtxDI7ELzcUu2KlbnQ8FFK+p8HqsYhuH
         Sf0TIsyFtxfUQ5VNyPcwyaScrRqwnMYzuMILJ39EL6heJ5OI5EOWDwLvYaEfwFL4BAtU
         n3AA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8-v6si968994ejy.275.2019.01.30.07.15.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 07:15:59 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 74A5AAF1C;
	Wed, 30 Jan 2019 15:15:58 +0000 (UTC)
Date: Wed, 30 Jan 2019 16:15:55 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Florian Weimer <fweimer@redhat.com>
cc: Vlastimil Babka <vbabka@suse.cz>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
    Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
    "Kirill A . Shutemov" <kirill@shutemov.name>, 
    Daniel Gruss <daniel@gruss.cc>
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
In-Reply-To: <87munii3uj.fsf@oldenburg2.str.redhat.com>
Message-ID: <nycvar.YFH.7.76.1901301614501.6626@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz> <87munii3uj.fsf@oldenburg2.str.redhat.com>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2019, Florian Weimer wrote:

> > preadv2(RWF_NOWAIT) can be used to open a side-channel to pagecache
> > contents, as it reveals metadata about residency of pages in
> > pagecache.
> >
> > If preadv2(RWF_NOWAIT) returns immediately, it provides a clear "page
> > not resident" information, and vice versa.
> >
> > Close that sidechannel by always initiating readahead on the cache if
> > we encounter a cache miss for preadv2(RWF_NOWAIT); with that in place,
> > probing the pagecache residency itself will actually populate the
> > cache, making the sidechannel useless.
> 
> I think this needs to use a different flag because the semantics are so
> much different.  If I understand this change correctly, previously,
> RWF_NOWAIT essentially avoided any I/O, and now it does not.

It still avoid synchronous I/O, due to this code still being in place:

                if (!PageUptodate(page)) {
                        if (iocb->ki_flags & IOCB_NOWAIT) {
                                put_page(page);
                                goto would_block;
                        }

but goes the would_block path only after initiating asynchronous 
readahead.

-- 
Jiri Kosina
SUSE Labs

