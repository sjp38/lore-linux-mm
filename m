Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33BA7C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 07:34:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E506420644
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 07:34:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IL8kpvCE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E506420644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 622776B0003; Tue, 17 Sep 2019 03:34:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D0EE6B0005; Tue, 17 Sep 2019 03:34:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C0426B0006; Tue, 17 Sep 2019 03:34:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id 259116B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 03:34:49 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D4232180AD802
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 07:34:48 +0000 (UTC)
X-FDA: 75943600656.23.ship72_642b52ccd5720
X-HE-Tag: ship72_642b52ccd5720
X-Filterd-Recvd-Size: 4193
Received: from mail-wr1-f68.google.com (mail-wr1-f68.google.com [209.85.221.68])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 07:34:48 +0000 (UTC)
Received: by mail-wr1-f68.google.com with SMTP id o18so1889633wrv.13
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 00:34:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=xs5COs3IFBd+FU/QFyQ3V/NOMrJdgrZhptW2Dami03g=;
        b=IL8kpvCE28nFFBT5ewdnx0MtB6s7TsEGoptgdI4Y+30ms6qfnxHYUM+UtkEylM/2CG
         2iM5TOPcuukLf1Mz+aovOvsWokmGozZ2WstnF0Rm5BiNGGaIm9Owvhs6U6Q0sVhId9P/
         ORz+sMoWT7j0vJkQ4+izd4AX6x/xA6+mWHGzlheOJgnq1L/FSSKFxbrLMS4hnWCcoDUx
         6EBhrnADj/hhlNhN4wKW71yXSmLI+KgHHtrgvd1YKNv96XffMqpIOwjaF9b7cJqOD7/o
         QO1jgvezxWUmWc+c6x/7BxtxDvud6P/TmSEYOh6jdaxB4vI18J1msXrcBUp0OsOBoPGK
         4EUQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:mime-version
         :content-disposition:user-agent;
        bh=xs5COs3IFBd+FU/QFyQ3V/NOMrJdgrZhptW2Dami03g=;
        b=lkJr+UqRv7xEwKFA+BhumHi63qEJ/H7Q8XFK+0Za1jo5KImBczgwGh26caW/7do7Xo
         GuKXdcnPCiq6ChQ49bPELgpPAlRdhciHf+BRzMo4fj5fIvGWQ5PvZdE1bv4hSUHc43b6
         GKvlWiqim8Oa/Ovk4i2wC2eUvoGzlyMNFH4xYAG1b13hWASBwIXaWbsm5+eB6eK0kkcy
         Clasrvj4XL8mAghN0AdLcY4CEjEoxWFmy1VVWcR42hDhLwg7CMvrSJWVIzc/vJ6w+YVN
         MBJgW0XtsVpbUNoboMBozyXF+PP+G0YcbsAbOHgEZABQjW0QhJ8aeFsyQzpqRGfhRime
         uKXQ==
X-Gm-Message-State: APjAAAWbN0j98/e5HqpxEgS/OZMhk2quT03dcT5jrpB3PwW6eCspUADl
	ter7PU+oW2GWKdxgH2wnN1s=
X-Google-Smtp-Source: APXvYqzc9gk0rGJOd6X1aLB0zOg4Owp7daVyjtd6vMkyJuFXT0Ltseh/ttbZCjDjiJi1ywrIedUZpA==
X-Received: by 2002:a5d:46c4:: with SMTP id g4mr1596417wrs.189.1568705686890;
        Tue, 17 Sep 2019 00:34:46 -0700 (PDT)
Received: from archlinux-threadripper ([2a01:4f8:222:2f1b::2])
        by smtp.gmail.com with ESMTPSA id s19sm1494984wrb.14.2019.09.17.00.34.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Sep 2019 00:34:46 -0700 (PDT)
Date: Tue, 17 Sep 2019 00:34:44 -0700
From: Nathan Chancellor <natechancellor@gmail.com>
To: Mike Kravetz <mike.kravetz@oracle.com>,
	Davidlohr Bueso <dave@stgolabs.net>
Cc: Nick Desaulniers <ndesaulniers@google.com>,
	Ilie Halip <ilie.halip@gmail.com>,
	David Bolvansky <david.bolvansky@gmail.com>, linux-mm@kvack.org,
	clang-built-linux@googlegroups.com
Subject: -Wsizeof-array-div in mm/hugetlb.c
Message-ID: <20190917073444.GA14505@archlinux-threadripper>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.085813, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Clang recently added a new diagnostic in r371605, -Wsizeof-array-div,
that tries to warn when sizeof(X) / sizeof(Y) does not compute the
number of elements in an array X (i.e., sizeof(Y) is wrong). See that
commit for more details:

https://github.com/llvm/llvm-project/commit/3240ad4ced0d3223149b72a4fc2a4d9b67589427

There is a warning in mm/hugetlb.c in hugetlb_fault_mutex_hash:

mm/hugetlb.c:4055:40: warning: expression does not compute the number of
elements in this array; element type is 'unsigned long', not 'u32' (aka
'unsigned int') [-Wsizeof-array-div]
        hash = jhash2((u32 *)&key, sizeof(key)/sizeof(u32), 0);
                                          ~~~ ^
mm/hugetlb.c:4049:16: note: array 'key' declared here
        unsigned long key[2];
                      ^
1 warning generated.

Should this warning be silenced? What is the reasoning behind having key
be an array of unsigned longs but representing it as an array of u32s?
Would it be better to avoid the cast and have it just be an array of
u32s directly? I am not familiar with this code so I may be naive for
asking such questions but we'd like to get these warnings cleaned up so
that this warning can be useful down the road.

Cheers,
Nathan

