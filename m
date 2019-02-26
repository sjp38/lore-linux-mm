Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14148C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 00:03:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2A3F218AE
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 00:03:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="PJJsUkox"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2A3F218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6313E8E000C; Mon, 25 Feb 2019 19:03:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B7CE8E000A; Mon, 25 Feb 2019 19:03:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4596E8E000C; Mon, 25 Feb 2019 19:03:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8858E000A
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 19:03:40 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k5so10869113qte.0
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:03:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=nTyz3nhhRJAnQKCmBEdqx7AWOxz2VXU5sIgb32iHM/w=;
        b=FGznf5fiaiWRo7Buf8sKUXTj574P+HWpB8HnIcEdjmFmZMOKFSvLwDBMbZZlz9M18+
         Wj2hzVv4OTPus1SpsYAXSfc/df1a90RB6Hs8LFzFekpMFIvCU0liiE+MG1DSE0PipGuF
         AVn7jUPqldZJu0rBMElSNwyw7L5jFSpwDAiiT6ALd5rHiro2yMGCs5YVpFZPwOnVkvVd
         olz0qk+OqlZmloJrHF4a6gChAh2nSpOSeIGNnjxuV8ZzGLdv8zot2sF7zYvWY0UO8k8x
         DLOE8qJ+QlB/k2+6fznWaAUScPe1uoc9v4hbsSKkOFf1CDza/uJNJ20gDSCq3hbK8gzi
         kjQQ==
X-Gm-Message-State: AHQUAuY/WERY/XhdtT39djLn0gbasIZ5suPP2yoieg27LxwS4ULJrL0a
	RC54eY/MMD9dkEGxTxKWpvIOnam4SMZS8JDqCTl3sloI9LfunLiQ4AV09dFfmfMah7psIGG7jOg
	Zhd9rUyspcPTPgFzpxd2b2LiV1mOlkoBcqYT1wuf+8XFa2/iLfp9k/EkI3CdfYMZ9ukiqLanY2r
	U8BoJFJKYVXmc/bBYNMdWAhT1+vk+G7LIlJy+Nfcu3E5QNY67LTF5PGdB4A7kKGjH8LaR/wGYc2
	kVhIF1L/1LIOMUfo3duLrSefKHblkVXn+5n+zOVZLpX+0PQ3KABkrgN+zmmpqLzMDUX/lzYDc4y
	sqc4G96uwU9H+yog4hASxWsDeUIVdw5dkkMATPRl8GQRSR3DnEM9i86Wf2JLsGuxaAdiha6GH+u
	y
X-Received: by 2002:ac8:1851:: with SMTP id n17mr170247qtk.42.1551139419845;
        Mon, 25 Feb 2019 16:03:39 -0800 (PST)
X-Received: by 2002:ac8:1851:: with SMTP id n17mr170188qtk.42.1551139418662;
        Mon, 25 Feb 2019 16:03:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551139418; cv=none;
        d=google.com; s=arc-20160816;
        b=cAI04tII9Jyn9z0FTpiljdaeXEI13kYZu9FfN3z9Zz/3/W1GyGyL7AVkU2Dse1IN45
         BgZQPar1Ixzdbne9aekBvTSzw2gdODqaCvkkC3lj9PM1+kQYWCt++2B6v7BjszAPJunj
         F1WbKXWNdzQjaxNQsNb+RlkoSH4N2XwieW1E1vymtRVZpUETPkpGptawB+/g5jRIjfu/
         xVm/OaDINeRNPgJ8bS+8UaAoExfGso/GkGBczOctso7afwfP0HIDRYOOm3/6oMay0e9x
         MMKLxwl9xlZwR1N+jjLV2Kn2Uzx/ws0gaUig4dULXQngjYDIGZeOboxs1mf5K10mnZjv
         4PEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=nTyz3nhhRJAnQKCmBEdqx7AWOxz2VXU5sIgb32iHM/w=;
        b=oyXJsLd4Z+Hpf2w/cNTo56iVqsI5FJhodnWru/uuqQ5hAGqP6apsZXmES2Rb8b4biT
         ixkRfeGOavCQb5yW8zDn3Er4i+jvCJy7j4Totg3h3buDka4xNdk3ZOH7w0Bwt0R78uCD
         edfE3Y6NkpBkdE9yF/MN0u4x0LAh6CWeLDy5ueeQ3BWBBl5XNer9x+onO+mu6GVS4ZN3
         12KQnpdMaNnNOhzLZZtZBRFdkvdJ0cJOphzB7sZvU69GHZzkUsp9jje2bitQ9psAmqoN
         5uumwULJSvqXAWTxqWEqTdQ1CnG3zfYIyY5B+KEzfV1K3aa4eO0jBJgtnQlnLTHZa7VE
         EkiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=PJJsUkox;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b27sor13591458qte.63.2019.02.25.16.03.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 16:03:38 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=PJJsUkox;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=nTyz3nhhRJAnQKCmBEdqx7AWOxz2VXU5sIgb32iHM/w=;
        b=PJJsUkox6+CF/dkHN/mWvihVRBMQXaHtCiEK3yJYAb26Tnfg3gdEmPvv/P7OJSRryw
         EwoaelNhNXnt48CV6HmkElLK/lu0JFMFftzxEkZbHBXWOO/u4FrvWRouZOm2jiDUMDK+
         8t6zAp0mzvSZYCxIae8QNfmbe1iV1FXNJ+J6XXCXi6wiK2VDHqFxNAAYEWH5XEqm7Nsn
         9wcxN8A9r66KZTvMxvKt0fX1Fv/jQrIRUNQVcBefS6kjMtPnlv8uLO8iwOeIprTMyG/u
         cyc70TkE9lmuapdwSWKEFkF9aSaZB1N1gFpyD/yCaAdnI18EaAm9qdFR8A0Z/GXzDCEq
         6BCw==
X-Google-Smtp-Source: AHgI3IY3Rv9382UHR/eB55SAV2oFmZhY4NP5S3bSRzOz/Z3hwV7neRHhA0HwE0IAIdN7HevRouSW8Q==
X-Received: by 2002:ac8:1e15:: with SMTP id n21mr16392133qtl.342.1551139418281;
        Mon, 25 Feb 2019 16:03:38 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id z140sm6241992qka.81.2019.02.25.16.03.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 16:03:37 -0800 (PST)
Subject: Re: [PATCH] tmpfs: fix uninitialized return value in shmem_link
To: Linus Torvalds <torvalds@linux-foundation.org>,
 Hugh Dickins <hughd@google.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Matej Kupljen <matej.kupljen@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
 Dan Carpenter <dan.carpenter@oracle.com>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
References: <20190221222123.GC6474@magnolia>
 <alpine.LSU.2.11.1902222222570.1594@eggly.anvils>
 <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com>
 <alpine.LSU.2.11.1902251214220.8973@eggly.anvils>
 <CAHk-=whP-9yPAWuJDwA6+rQ-9owuYZgmrMA9AqO3EGJVefe8vg@mail.gmail.com>
 <CAHk-=wiwAXaRXjHxasNMy5DHEMiui5XBTL3aO1i6Ja04qhY4gA@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <86649ee4-9794-77a3-502c-f4cd10019c36@lca.pw>
Date: Mon, 25 Feb 2019 19:03:36 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAHk-=wiwAXaRXjHxasNMy5DHEMiui5XBTL3aO1i6Ja04qhY4gA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/25/19 6:58 PM, Linus Torvalds wrote:
> On Mon, Feb 25, 2019 at 2:34 PM Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> On Mon, Feb 25, 2019 at 12:34 PM Hugh Dickins <hughd@google.com> wrote:
>>>
>>> Seems like a gcc bug? But I don't have a decent recent gcc to hand
>>> to submit a proper report, hope someone else can shed light on it.
>>
>> I don't have a _very_ recent gcc either [..]
> 
> Well, that was quick. Yup, it's considered a gcc bug.
> 
> Sadly, it's just a different version of a really old bug:
> 
>     https://gcc.gnu.org/bugzilla/show_bug.cgi?id=18501
> 
> which goes back to 2004.
> 
> Which I guess means we should not expect this to be fixed in gcc any time soon.
> 
> The *good* news (I guess) is that if we have other situations with
> that pattern, and that lack of warning, it really is because gcc will
> have generated code as if it was initialized (to the value that we
> tested it must have been in the one basic block where it *was*
> initialized).
> 
> So it won't leak random kernel data, and with the common error
> condition case (like in this example - checking that we didn't have an
> error) it will actually end up doing the right thing.
> 
> Entirely by mistake, and without a warniing, but still.. It could have
> been much worse. Basically at least for this pattern, "lack of
> warning" ends up meaning "it got initialized to the expected value".
> 
> Of course, that's just gcc. I have no idea what llvm ends up doing.
> 

Clang 7.0:

# clang  -O2 -S -Wall /tmp/test.c
/tmp/test.c:46:6: warning: variable 'ret' is used uninitialized whenever 'if'
condition is false [-Wsometimes-uninitialized]
        if (inode->i_nlink) {
            ^~~~~~~~~~~~~~
/tmp/test.c:60:9: note: uninitialized use occurs here
        return ret;
               ^~~
/tmp/test.c:46:2: note: remove the 'if' if its condition is always true
        if (inode->i_nlink) {
        ^~~~~~~~~~~~~~~~~~~~
/tmp/test.c:37:9: note: initialize the variable 'ret' to silence this warning
        int ret;
               ^
                = 0
1 warning generated.

