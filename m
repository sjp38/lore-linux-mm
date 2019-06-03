Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2175C46460
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:34:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA6F226F7D
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:34:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iX/ZKmV0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA6F226F7D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1259F6B000E; Mon,  3 Jun 2019 12:34:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D67D6B0010; Mon,  3 Jun 2019 12:34:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE0466B0266; Mon,  3 Jun 2019 12:34:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEB386B000E
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:34:02 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id t141so17206209ywe.23
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:34:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NS9jbidsTjt8uIbLTVUhJinXzdbo3OkZBbHkpb2WV0A=;
        b=skobuAjuzxrdHWgyPpKWchef2C62jAPutLif0Ad1yUiidJ3DowP6cUJ7UzQsj02Sgr
         kSnWelFuEPV8UcshAvPfbFhTaTExvUuHz0EqtMnDPcBBI0qakSCgpNhf3/Xtv1i44Amt
         eFq8TPlSUkOue7glvjwBSyeOHpxD4/4ynRr0r57SJmai+K2NdxT1uJxal7pxfvUyG29Q
         b3vgrlVj9mcgU8DjIDFcd84qpFUH5VEbdiZfOowj06kKH/tccCKy2+046i8OXoJVDmKg
         yf0bCKNAvKp3QQu6tPMKfYg4JyXCnWh33wqZVVqrr6mrNzsdFq3RiseBfepFx41pKeLD
         aSwg==
X-Gm-Message-State: APjAAAVLKohljT1gr0q/FNaCivZ3cTmBKEvse5Y4fo0fpQNFJxmzg9hi
	GiiC1GXy98XeqohyRZew47Z8HuPOSzvZ3+Nf/kgd6FfwZYUgdIStuXZ+7FYdiqRRg+b+a2B+CcJ
	6Pl5cEWKmHTL2kZNqPgZGYDIDwuMpTRe0kLSepHlsNJvvqncziBVbAiYiSyNVQdfzQQ==
X-Received: by 2002:a25:138a:: with SMTP id 132mr11841442ybt.127.1559579642473;
        Mon, 03 Jun 2019 09:34:02 -0700 (PDT)
X-Received: by 2002:a25:138a:: with SMTP id 132mr11841416ybt.127.1559579641855;
        Mon, 03 Jun 2019 09:34:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559579641; cv=none;
        d=google.com; s=arc-20160816;
        b=YGNBENmR0fwHtKxKwljU4PdI4yF5gcDbft8/x7ipSILz1AG9N9zVJSx+gWhHfQw9R4
         yRZdp+EHJOEAw4exOp/z2blrWgTVgE3BAG3CTmpeVVQJomnYIvZkJs4JoK/aWkDq1nTw
         bqTpj4EWk05GfICGZXO+HmdF7mE/sWd1TjiLkSaaHgaO0IGbHMGvdclsnZsHZODF46Cp
         TICGejIcT6qGswc0WlkJenyMyUETd6KckOG05vCwyYB4sv9l2r60k6bUJEDmk2/zx+WI
         oLTUA44G73HP7sM+VRv303sXoQQPFgZNxgVEGgACUrIc40RRzXjNi6AEedxBp9PorkjX
         n8ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NS9jbidsTjt8uIbLTVUhJinXzdbo3OkZBbHkpb2WV0A=;
        b=fwuq7cF9fNhE+KV9RgefBDeP9ae+LuM4Yrgec4YJ3+1Tj6dcpfnAddL2oFeDlhek12
         5+nY1klZyOudD9sBEh8OcoEVTPqPvzzldt/Fcs7vYL/PB4hozCnoLQ6FPkoUpp7P3XU8
         6AYtKpk6vJxfmtScRhSBWEjwc4SEEFT0JtV9XQH43KJH068vcYFSNJkMACDtfFbbVYW9
         8Mw07v6psJxYIQquWsEIhl2WxvO2NRtDQXtdEya6Ffj0DdooTe/Z44VL/j0/xk4NX9sC
         +Hkmw/xXfJBa/BNBTNKzZmcsicWYxkhogtpbeLZkJ/fHFXN1gxxPi0FBWJFkoUEpTCnh
         beDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="iX/ZKmV0";
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16sor1070360ywm.72.2019.06.03.09.34.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:34:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="iX/ZKmV0";
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NS9jbidsTjt8uIbLTVUhJinXzdbo3OkZBbHkpb2WV0A=;
        b=iX/ZKmV0z83R3UhFOkARskTLTPJIZOXfQUJAbRUJFdrMUnL/XlR8M5SsYDttKL5j1p
         HybqQq4bQxHv39uhOnXWvcw1M/dMmDE0idCPsfOa37keaAUa/Fbl2pb7Ar0+h3KAeaf7
         jlXJm6Y/BhyHlY99QuUu4vhioWImBsYQVyVhFDJr41e85NnrO4ps8xUzssMXUbnIQ76v
         fIAoPQczSMQstITZ3yNRjjJJ0BJjT6YQ0P7Ee2ubdCjxun884Hy8KVUEHWzuriJQAa/6
         z+nd9Umz3+ZqrVcSDNsqOLM9is8L+9xowStQg5pCFq7XJu2FXwqLZo9Zky4Qhw8zDPMz
         T4jw==
X-Google-Smtp-Source: APXvYqzEIndDah4HIBa5VMS14CjPN3RDSIYZXkRJOr5nlfrmuJIr8YVGC/nRNC/gLXBjX9LUe9kvNiOFWMnTZmDTNsg=
X-Received: by 2002:a81:7096:: with SMTP id l144mr15123361ywc.294.1559579641430;
 Mon, 03 Jun 2019 09:34:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190603132155.20600-1-jack@suse.cz> <20190603132155.20600-3-jack@suse.cz>
In-Reply-To: <20190603132155.20600-3-jack@suse.cz>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 3 Jun 2019 19:33:50 +0300
Message-ID: <CAOQ4uxgn7_tY35KVE6c-na2skXtxXhrM8-2wRNUe2CtmYACZrg@mail.gmail.com>
Subject: Re: [PATCH 2/2] ext4: Fix stale data exposure when read races with
 hole punch
To: Jan Kara <jack@suse.cz>
Cc: Ext4 <linux-ext4@vger.kernel.org>, Ted Tso <tytso@mit.edu>, 
	Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	stable <stable@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 4:22 PM Jan Kara <jack@suse.cz> wrote:
>
> Hole puching currently evicts pages from page cache and then goes on to
> remove blocks from the inode. This happens under both i_mmap_sem and
> i_rwsem held exclusively which provides appropriate serialization with
> racing page faults. However there is currently nothing that prevents
> ordinary read(2) from racing with the hole punch and instantiating page
> cache page after hole punching has evicted page cache but before it has
> removed blocks from the inode. This page cache page will be mapping soon
> to be freed block and that can lead to returning stale data to userspace
> or even filesystem corruption.
>
> Fix the problem by protecting reads as well as readahead requests with
> i_mmap_sem.
>

So ->write_iter() does not take  i_mmap_sem right?
and therefore mixed randrw workload is not expected to regress heavily
because of this change?

Did you test performance diff?
Here [1] I posted results of fio test that did x5 worse in xfs vs.
ext4, but I've
seen much worse cases.

Thanks,
Amir.

[1] https://lore.kernel.org/linux-fsdevel/CAOQ4uxhu=Qtme9RJ7uZXYXt0UE+=xD+OC4gQ9EYkDC1ap8Hizg@mail.gmail.com/

