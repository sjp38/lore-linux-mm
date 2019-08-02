Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4565EC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 21:25:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E71CF2087C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 21:25:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="G/mBVOBA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E71CF2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vandrovec.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DE966B0003; Fri,  2 Aug 2019 17:25:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68F596B0005; Fri,  2 Aug 2019 17:25:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 557F06B0006; Fri,  2 Aug 2019 17:25:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD216B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 17:25:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 8so42893482pgl.3
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 14:25:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:subject:to:cc:references
         :from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ounmn3+2vrtLO87mBqUZUFIlPArGl+FnX3GM8A0g5iQ=;
        b=hzgRXrA6nspaMYNLP2r5aSqOFOSwHyrECWj5RiismPOx03pqhcmtxbV71KdR6w/M4y
         Gm95LL4H0PXDFj9NCWFQJRwXivBCHrJL9sVSQxjGDpXinrH01JfIJT3f+NzTNBCEx7FM
         Ern1L3OkymuLzLN7howy5l88BYh5HRU+BDnjYSbmHg23QepBgxCnHeEnEqNWreruzqya
         fhIZgZS8SoXT+oar2w1SN7QevC0iUufYGw3+Oe2ElcPP8ZwT07Giso6wLL5wdTUCPXVZ
         11KWv0awq395f0bQQBufB4NxwzNBOioJ7tHHkPj6goBnYlESw4uHQYWvJF94wIoJL2AP
         7t2g==
X-Gm-Message-State: APjAAAVfruKKbX+MWOWoqJ0UkMyH1XvHzStPlb9qWV3O4Eicy9v7tOJF
	8Jc2umaoTQUJ5e3wD1X3lna6SUmE8YsximZaQFv15+K42rRBmTqbTvXjD3ys4pB8P02+Kn1YW2Y
	FQwNCoZ+o+EXKPojH02FOBkQmd6wwZbppQPc7Z5domoLV+R4GJUHlgfm3SpE37EA=
X-Received: by 2002:a62:1883:: with SMTP id 125mr61566079pfy.178.1564781120697;
        Fri, 02 Aug 2019 14:25:20 -0700 (PDT)
X-Received: by 2002:a62:1883:: with SMTP id 125mr61566047pfy.178.1564781120025;
        Fri, 02 Aug 2019 14:25:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564781120; cv=none;
        d=google.com; s=arc-20160816;
        b=OFLt9+X6uGwakotf20UswuZYi8qmNJZB8bk5mB/s4TaqcONVndOw1HlcIkWMDUvP2g
         8ePLPJwHUAMaqVNGd316LZyZ53w46m8qwRLiyYGwBvskg/k15KAJXGkockRsM/ZpGGQQ
         g4cIreANgigjCLHRcgz8f5J6/HXftQVexMR6nkiUejGbhJks4BJR+eKy4zcz2CWtGtin
         nLqNVk8H6xCN5O27MsVm+XAMo2IX4tIv1FwJ2eG+Q4Ld21bkqggcH1WimM4GqtSXFVoE
         ykkjpHJAL4tLCc4+BIRY1SDL60NztWr5xhhjw7z3mbiZHOW/lECGO5RcJjouyxZINe4E
         /b2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject:sender
         :dkim-signature;
        bh=ounmn3+2vrtLO87mBqUZUFIlPArGl+FnX3GM8A0g5iQ=;
        b=zHQwxz0qO59EVcsOk0BG3EgIL9bkvXNolWEs7wEmKIhqJx0XSrCsAsDc/EInrRisg6
         Eh+ZH7pDKi8SY5go5+4wdPPX1YfwcEFQA+dZDj+H1FOWFMmNSkLtWimgfdZKW5MDKCVi
         T9Ba4uomzInn3iDnDhnPKcSZYrbrTYZS83e4sQBawK4EJQDJzkufFLWsasOZ45aUHzSg
         84LjMCQio2UE07AHprkDUqK2S9TPCJ/NuQDxx5IuZpiZ+VVD9V6TTaZ0DyV86I53ocmA
         iQhhiDmhwO2NB0Xa27Ol0z1z2uNfZ6PpgukPbX7pbbRKDPwLlvckYTqCZzAhpTsb4RJ0
         6Ugw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="G/mBVOBA";
       spf=pass (google.com: domain of petrvandrovec@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=petrvandrovec@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g22sor58031353pfh.16.2019.08.02.14.25.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 14:25:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of petrvandrovec@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="G/mBVOBA";
       spf=pass (google.com: domain of petrvandrovec@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=petrvandrovec@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ounmn3+2vrtLO87mBqUZUFIlPArGl+FnX3GM8A0g5iQ=;
        b=G/mBVOBAXzvZJn9oR7C1invDeI1YxtKet2qnxDnbsDUXEpiXt0YUa2PPzxKQK5+6UX
         ONC8u2JfaskPMRmmZXTzF4+gYrS2SrjqSSf/54UQ7DnmxGtpqNgTh4RwORAF3iWzJ+in
         ChI8K5M9LzMnq1hDu4W7rS7eE/Y+G+47kU9vJwaXZGo/gP5wtTqRzE3wXJ49x0jwf1Gl
         bXlZ8q81lTr/qU4hAzC/9QCCFDujJYoSA9Xcftk6NEGcLBkV93l0E8p9VUDxCAudDSac
         /MAms025UMETpRqrdUKvyr6MQ1tPeuzh+K04iP+AKhKfPl6sJ1uu3h74eBsTjmeCmF2m
         vyXw==
X-Google-Smtp-Source: APXvYqyGVCV5HJGm1XNWnr4gOx/zbXJ5CT4KwBYp0MHUEXjgEgcj0pHURHUcwFLN51nH9nwVHhp36w==
X-Received: by 2002:aa7:9210:: with SMTP id 16mr63424213pfo.11.1564781119305;
        Fri, 02 Aug 2019 14:25:19 -0700 (PDT)
Received: from [192.168.1.219] (c-73-252-184-5.hsd1.ca.comcast.net. [73.252.184.5])
        by smtp.gmail.com with ESMTPSA id t6sm5463968pgu.23.2019.08.02.14.25.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 14:25:18 -0700 (PDT)
Subject: Re: [Bug 204407] New: Bad page state in process Xorg
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org,
 Christian Koenig <christian.koenig@amd.com>, Huang Rui <ray.huang@amd.com>,
 David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org
References: <bug-204407-27@https.bugzilla.kernel.org/>
 <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
From: Petr Vandrovec <petr@vandrovec.name>
Message-ID: <dbc18e46-fe01-27a1-e531-cbc1161d394b@vandrovec.name>
Date: Fri, 2 Aug 2019 14:25:14 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101
 PostboxApp/7.0.0b3
MIME-Version: 1.0
In-Reply-To: <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote on 8/2/2019 1:23 PM:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 01 Aug 2019 22:34:16 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> [259701.549382] Code: 10 e9 67 ff ff ff 0f 1f 44 00 00 48 8b 15 b1 6c 0c 00 f7
>> d8 64 89 02 48 c7 c0 ff ff ff ff e9 6b ff ff ff b8 0b 00 00 00 0f 05 <48> 3d 01
>> f0 ff ff 73 01 c3 48 8b 0d 89 6c 0c 00 f7 d8 64 89 01 48
>> [259701.549382] RSP: 002b:00007ffe529db138 EFLAGS: 00000206 ORIG_RAX:
>> 000000000000000b
>> [259701.549382] RAX: ffffffffffffffda RBX: 0000564a5eabce70 RCX:
>> 00007f504d0ec1d7
>> [259701.549382] RDX: 00007ffe529db140 RSI: 0000000000400000 RDI:
>> 00007f5044b65000
>> [259701.549382] RBP: 0000564a5eafe460 R08: 000000000000000b R09:
>> 000000010283e000
>> [259701.549382] R10: 0000000000000001 R11: 0000000000000206 R12:
>> 0000564a5e475b08
>> [259701.549382] R13: 0000564a5e475c80 R14: 00007ffe529db190 R15:
>> 0000000000000c80
>> [259701.707238] Disabling lock debugging due to kernel taint
> 
> I assume the above is misbehaviour in the DRM code?

Most probably.

When I switched back to 5.2, crashes were gone, but log was filled with 
11 millions of messages complaining about alloc_contig_range problems:

[22042.108043] alloc_contig_range: [106f118, 106f119) PFNs busy
[22042.114400] alloc_contig_range: [106f11c, 106f11d) PFNs busy
[22042.120787] alloc_contig_range: [106f11d, 106f11e) PFNs busy
[22047.093057] alloc_contig_range: 47963 callbacks suppressed
[22047.093058] alloc_contig_range: [106f117, 106f118) PFNs busy
[22047.105576] alloc_contig_range: [106f118, 106f119) PFNs busy
[22047.111937] alloc_contig_range: [106f11c, 106f11d) PFNs busy
[22047.118329] alloc_contig_range: [106f11d, 106f11e) PFNs busy

In total there is 9735 messages logged individually, and 11 million 
suppressed:

petr-dev3:~$ dmesg | grep alloc_contig.*PFNs | wc -l
9735
petr-dev3:~$ expr `echo \`dmesg | grep alloc_contig.*callbacks | cut -d' 
' -f3\` | sed -e 's/ / + /'g`
11333722

So it could be my problems are caused by new Xorg driver.

After I disabled CMA system is stable on 5.2.  I did not try 5.3-rc2 yet.

Petr

