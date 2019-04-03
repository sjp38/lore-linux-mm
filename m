Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14E8DC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:56:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9ECD2084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:56:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="ECT6lpn3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9ECD2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67BA76B000C; Wed,  3 Apr 2019 13:56:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62B676B027C; Wed,  3 Apr 2019 13:56:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51ADC6B027D; Wed,  3 Apr 2019 13:56:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 312A16B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:56:29 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n10so17551479qtk.9
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:56:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=PxDq6sqsxX3UdiY2YPlqWIL/OxZS2aP7l6arbZ0e3zs=;
        b=kaUBO7CEFRCbi9LsloQe39xAmQvMTtonJyUVeZXP6+jYLfvQOJH0KQtjyTHEgujh7+
         IApjXgwFkQeLzT45viN5cVyvOL8hbKmY2oTfoGlqzT7spJNBikR7ynG9b4S/rkwTd1ts
         zV/GwqKbWSAqAdvoaHCq9BhKkSBOfv2JMrmOVWY0CLoNMkKmTj9frH6ccGKx9GyoDduP
         ilrbIev9+dlnBtLRlWh+s2qoVwkWjMhK/TGkw98S9XOrwlY1bCTAlELm+kQ6wpfTDzyp
         WOjZyxpabpFLBm7KUL3igzRzXnxK2oqwi/qsCF3eEihyNn6iZiGFGqkfz2aJfms8y4/e
         NtOw==
X-Gm-Message-State: APjAAAWd4C2fSxosV8xO27GIiVukXnSdqkrFRMCXkKDq8dN1dRrM1kat
	hH1q6nGA0zt5qz2ij3Qdg42HkkyEPYgdBVM1Oik03GQxJwyX/p1YqjR7FFVR3xMW8ijNNnNVNeI
	dhuIYay9/9smNZ56z2tXRjYnVp5ow6hBZ/JGwFMVE9iL84ShM2z1LaqdqBC+WDog=
X-Received: by 2002:ac8:260f:: with SMTP id u15mr1194811qtu.109.1554314188887;
        Wed, 03 Apr 2019 10:56:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqj2fN03uRdRQ7uB4+DvgkuweWUCs9oJxbYDxPuQOyME9KqxUnO7qayGQtXjFaOsPDrE9T
X-Received: by 2002:ac8:260f:: with SMTP id u15mr1194759qtu.109.1554314188174;
        Wed, 03 Apr 2019 10:56:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554314188; cv=none;
        d=google.com; s=arc-20160816;
        b=HF0AGCDZkAlHfAz9MkY/QpoQ68An31iIPTcN4byJD3RZr+zJY6/IAh4xr7Z2eQ7nHS
         ii9ncxPuW1OZbQOTvcl7EUnTeAs3ffeDUMQ6llmzcsrLVTp4JcSYPQ44mvz33O6FWnJM
         qe/o2aBpag26DPU0WcJn5gN5LF7p/UkxxPRBmRIZVgUCddt6zbCbDIORGgJdMSrXfvfI
         P7+rBK91kr0gHT/+zaPAhOzmKlRFKKpJz5+cLiIFJQ6wyJdsIx/nXPEQBumLdop8NQgm
         8m3tSqe32uY+iCQvkYQtHh9Y0roqE5zSx1SnLKf99q5oY79MnQ3wHQyew1jPlrDQepPy
         rU0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=PxDq6sqsxX3UdiY2YPlqWIL/OxZS2aP7l6arbZ0e3zs=;
        b=IPCvXIaCeKDkndYOBrAKuR1p/4xbnib1B9j6CJT0RuFjtzYTU1tf2rQSo1GC6YKF81
         JUSkRK0l+7ZWXFAKBId4QVN22ZZAfiV7O8Gn+HdIqhaKHcItPGDzWetpuQWL8KFMjXxU
         ueB92kg2osd4NueT/hA8OER3ylWTe8TK5d37Sza3YkEVRsXhCOriP82MHeQH/DEhDs+D
         Vcw8sWEi5SeNQ5QBXpDZshBMOKBtwcqMie24wjF9DoWS1fLcUSmjj8fKKU+ARFYAqTh/
         iMwaOgYDvF/Pu4f9rpwPs4v0VEu+poT3cLp+y6DM0iP25BZ13E7LU8k7eMsF3nzJca9W
         QbkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ECT6lpn3;
       spf=pass (google.com: domain of 01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@amazonses.com
Received: from a9-37.smtp-out.amazonses.com (a9-37.smtp-out.amazonses.com. [54.240.9.37])
        by mx.google.com with ESMTPS id a2si853762qkl.123.2019.04.03.10.56.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Apr 2019 10:56:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@amazonses.com designates 54.240.9.37 as permitted sender) client-ip=54.240.9.37;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ECT6lpn3;
       spf=pass (google.com: domain of 01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554314187;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=Wyd/86VQr4yB+T3sAKBmvWlFZRyqyhljETAB3MKNVBw=;
	b=ECT6lpn36hcc5RiE9hxy2iLqLJPNP+ceZdI1xVdCLGsleGlkdonBVCwBaMVznKj4
	9CTvSAAFdKBjZ5hY26du2Zk6Bwpjfzk1DQnCiRgMlrd7d6F9fC1XJwzxF8Lb0VLl5iT
	ZVRQU9YU3p/X/L7Wsb55owNa6j6s7KblS1qdWtJ0=
Date: Wed, 3 Apr 2019 17:56:27 +0000
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
In-Reply-To: <20190403170811.GR2217@ZenIV.linux.org.uk>
Message-ID: <01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@email.amazonses.com>
References: <20190403042127.18755-1-tobin@kernel.org> <20190403042127.18755-15-tobin@kernel.org> <20190403170811.GR2217@ZenIV.linux.org.uk>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.03-54.240.9.37
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Apr 2019, Al Viro wrote:

> Let's do d_invalidate() on random dentries and hope they go away.
> With convoluted and brittle logics for deciding which ones to
> spare, which is actually wrong.  This will pick mountpoints
> and tear them out, to start with.
>
> NAKed-by: Al Viro <viro@zeniv.linux.org.uk>
>
> And this is a NAK for the entire approach; if it has a positive refcount,
> LEAVE IT ALONE.  Period.  Don't play this kind of games, they are wrong.
> d_invalidate() is not something that can be done to an arbitrary dentry.

Well could you help us figure out how to do it the right way? We (the MM
guys) are having a hard time not being familiar with the filesystem stuff.

This is an RFC and we want to know how to do this right.

