Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0253C5B578
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 03:07:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F842206A2
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 03:07:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Al5//5gO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F842206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEB736B0006; Mon,  1 Jul 2019 23:07:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D74C58E0003; Mon,  1 Jul 2019 23:07:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC7B38E0002; Mon,  1 Jul 2019 23:07:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82F4D6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 23:07:33 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so10026278pfi.6
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 20:07:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=JEjj/PPo3yxC7A/OXv38wkR3+utyXU9OEcFxU+K+Oro=;
        b=P+X6miRfgqmm0fpul8u5QKbalmFJJgfWjOwQAPnY5D+/tmcW/2GMrMX/3bTEoYMyM4
         TwR4eOx+FGozsPrPvr/7OX39CIaSqgZd0xf3kA13leRHWQV39AnlwKRRWOZXJz60z7W6
         T23oa+CWU5hADKeemrST0IoNx1/GTaehng/ER+CkfZBFB3nwegBYnOib/Nea9u8oU3IS
         aeicPiChRFz4ZZRZW1WhhxVqa4VebkMypUGKD+9ysEZ2iUdCdhw/DgTIKuT+TvYXjMX+
         U1A3Ic0EHY7ONUoIItXiuc/dp53vH6lKaACmg5WF/CgFIemzfmDTbNhmWQidpOzGRCUl
         kJJw==
X-Gm-Message-State: APjAAAWCCvFP4Y4tOuKys3eCWKaLRd1U5wvk0mOhIpbTohwLnt9WAApz
	4tByWBmSCLssS1yXnSPhRtMv6WKtzr1tv8mJ64f7/4cWl+W+2RXop5Xji7NQ/svGUiFFHTxYGQ+
	sY8VBuxGT5wKkIKJjqocid2pNr3BujNJWlbFGDEGB6/ErHGYiJGy/1WLDmsnyZK1L7w==
X-Received: by 2002:a17:902:29c3:: with SMTP id h61mr32226922plb.37.1562036853098;
        Mon, 01 Jul 2019 20:07:33 -0700 (PDT)
X-Received: by 2002:a17:902:29c3:: with SMTP id h61mr32226852plb.37.1562036852116;
        Mon, 01 Jul 2019 20:07:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562036852; cv=none;
        d=google.com; s=arc-20160816;
        b=v8GCjvnYUrklANmcAMapS7ofFadhW8EvpzSZlt+7/QWGQtddNch83p4frxqis6BfSg
         jCTVj/l30L1MM3jO0DknaH5eFMGfUaRqIfoHhab0in3khIEU/ZwF9hSc37gm8KFhU8Ai
         bKUmfKBYS+jEWrlEBzkplafp2t5FwyReEp0SMxqvSkcrOwjdUKdiw0tnDBjnshZmCrL9
         NMHcUWMJQu5g8GeLqe8qvlsOv8OShKIGCWd+OjppGqj4uBHMRiaqedOoYksV7+p158TM
         0u83IArMEin6GbA60rVCUyOFJhckifNdwiOq+vQa52sgOQYbEXaotF+34+t9bKJjKu1A
         aVKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=JEjj/PPo3yxC7A/OXv38wkR3+utyXU9OEcFxU+K+Oro=;
        b=TvyEj7HmFuyh8ee33/mTf5hDgzS1SQoNJ/BOtzZ4L7SCdTMqzHmFIyrIb2YC4O5dSu
         kuxVBc10sprZlQlK8grDESleFio4GxzKV25XiHnW8WC6j2rmZGEzIFmEEmwHbcVzlri9
         3JPyX4AfxHZYaRW+khcVg77oKVu88aLjgMtw9qCoxWcsQtYRFbn2OyImvEBPHBDW3Apf
         rnH7lLBIvxwBTQdq5Kh2JiQ6aptt7m2uGZJYopL0Bu/Ra99pyJkMOQCyQt/UpiNrhX9f
         NFc+JsMCdvSHRwj+AQ8yDiYKAT2tpaUYTN46Mx6NiKkZ4EX1zxP2WPf5WjlUqJc9WWS+
         3Tjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Al5//5gO";
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor6383992pfn.15.2019.07.01.20.07.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 20:07:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Al5//5gO";
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=JEjj/PPo3yxC7A/OXv38wkR3+utyXU9OEcFxU+K+Oro=;
        b=Al5//5gOeoq+S2jUF4fWN70LRFW/gTgt2BAn2B0baRvM15+mvep+e5s4otLVXnFidS
         xBIE1sEHhvdBjGVQNKvZJxJgS3UdF4SDPQWO2bZ1qZ6vVx4wQIRlG/Q0PHTSe7GdH1CN
         9cMVFo4aSiPy+/dKIODZEmbH7MLbzA/dmpvmep3x/AmEilTks2v/Y+pWLjIn9LQ0PH9R
         y3GTlAck0dxdUgSPhIuZPl2WokIMtkaDzckYgT3LAIei69JVQwqvYIY52W+nZxNG0pqj
         e8Okec5QN1hZ74rwLSruZokYUZf+wjNVH5HrnYrKVrKxKFTKrXBjDp1EUoQxYsO+hF7X
         1bMg==
X-Google-Smtp-Source: APXvYqxOVg0HFcmLKK0QMTMU/kWLAUMGqHvjW+x4ulftF7VETnHP5SSk6O+UdayEdNaJVHGmMdn0Lw==
X-Received: by 2002:a65:6102:: with SMTP id z2mr27238296pgu.194.1562036851675;
        Mon, 01 Jul 2019 20:07:31 -0700 (PDT)
Received: from localhost ([175.45.73.101])
        by smtp.gmail.com with ESMTPSA id f11sm10274123pga.59.2019.07.01.20.07.30
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 01 Jul 2019 20:07:30 -0700 (PDT)
Date: Tue, 02 Jul 2019 13:07:11 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: Re: [PATCH 1/3] arm64: mm: Add p?d_large() definitions
To: Steven Price <steven.price@arm.com>, Will Deacon <will@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual
	<anshuman.khandual@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Catalin Marinas <catalin.marinas@arm.com>, Christophe Leroy
	<christophe.leroy@c-s.fr>, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Mark Rutland
	<mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>
References: <20190623094446.28722-1-npiggin@gmail.com>
	<20190623094446.28722-2-npiggin@gmail.com>
	<20190701092756.s4u5rdjr7gazvu66@willie-the-truck>
	<3d002af8-d8cd-f750-132e-12109e1e3039@arm.com>
	<20190701101510.qup3nd6vm6cbdgjv@willie-the-truck>
In-Reply-To: <20190701101510.qup3nd6vm6cbdgjv@willie-the-truck>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1562036522.cz5nnz6ri2.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Will Deacon's on July 1, 2019 8:15 pm:
> On Mon, Jul 01, 2019 at 11:03:51AM +0100, Steven Price wrote:
>> On 01/07/2019 10:27, Will Deacon wrote:
>> > On Sun, Jun 23, 2019 at 07:44:44PM +1000, Nicholas Piggin wrote:
>> >> walk_page_range() is going to be allowed to walk page tables other th=
an
>> >> those of user space. For this it needs to know when it has reached a
>> >> 'leaf' entry in the page tables. This information will be provided by=
 the
>> >> p?d_large() functions/macros.
>> >=20
>> > I can't remember whether or not I asked this before, but why not call
>> > this macro p?d_leaf() if that's what it's identifying? "Large" and "hu=
ge"
>> > are usually synonymous, so I find this naming needlessly confusing bas=
ed
>> > on this patch in isolation.

Those page table macro names are horrible. Large, huge, leaf, wtf?
They could do with a sensible renaming. But this series just follows
naming that's alreay there on x86.

Thanks,
Nick
=

