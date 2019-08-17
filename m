Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3842C3A59D
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 00:20:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89E602077C
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 00:20:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e1rJtASL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89E602077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vandrovec.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2111D6B0007; Fri, 16 Aug 2019 20:20:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C2336B000A; Fri, 16 Aug 2019 20:20:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D9226B000C; Fri, 16 Aug 2019 20:20:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id E0E136B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 20:20:51 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7C43F173FF
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 00:20:51 +0000 (UTC)
X-FDA: 75830014302.28.face56_24878d9564a2d
X-HE-Tag: face56_24878d9564a2d
X-Filterd-Recvd-Size: 4778
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 00:20:50 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id q139so3908944pfc.13
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:20:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=D0kbC6F7vVOkq6Rzvvsj1BprmGjj2NrtMTriJSxu1QI=;
        b=e1rJtASL2RfhvynkwFe3EUPTZ3xDFZKU4ML86Q66iNgVKOFbtYOAsasJ2QAzhML6DO
         WXokfFk55wzrwNe5uViKMzAgxnfYewhrFryHdb6t74xGe3LckJWCnnrP+sXRAGkT8ErL
         +yaJf71XO+lAIu5Kg8K1rjbeFPHDTMze5WI2H0JitwK+gytxpSslgHEq3poIgBm75q7K
         30ER5HF9mLSkmgobumI4+j9ygzex+JqkT9doGJMaFM72YWg3K9DiUj/9K12GU0fXXmxl
         7lpJRsdajS+pfg+lFzR8ZFRD2wohdtJKf/x7CNaw00+QhB+ZJW0iILBMQ1KdKmMFu7Hd
         Pprw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:to:cc:references:from:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=D0kbC6F7vVOkq6Rzvvsj1BprmGjj2NrtMTriJSxu1QI=;
        b=LcG44EXmnxZTB76SfFWaUq2sUVeXl+1mZHo0lM2wFqNRYAQJHN/HbOdOdyzWXHS5Re
         XPQnRz2SXjawOTtDSzpC5u1WU2ieBKtdai0fv4FXpTqRRC7qaPlWBd/+CnDgFhfuZgOZ
         Y3qfDbEMdxlFk1EzkLl1+a7c1Y2Za5s6DpromI+kSXN0f/tOesKGkmK6ZgHzwwi0PKkf
         Z3HPYfzUvjXt5zRFe5w9NMfM92Q13QF9WxB/bwbZN7qgVPSJUbTBR0+gjf92cwYSWHxw
         stNEcuF2oRPZhZtmH9aTErx1l+UQ/9trK73KD1Wan78uR0N7MzGXSkIVTxS5nCAD4q9q
         HmVQ==
X-Gm-Message-State: APjAAAURGxOpKolxyyN/YUp13UZEbKDN+C3hE51kVU8jVcLqR092+Iav
	Xb6yp1SeBYRyMJ3PB0XHHA8=
X-Google-Smtp-Source: APXvYqyCvPvn4Gs6NL8NdNRw0/8JH9Y8L8dex7TJJ8Xal2ZqZGu6YPzosZc3+zwG7oULya9WwUeUHw==
X-Received: by 2002:a62:f208:: with SMTP id m8mr12957531pfh.108.1566001249601;
        Fri, 16 Aug 2019 17:20:49 -0700 (PDT)
Received: from [10.1.192.154] ([66.170.99.95])
        by smtp.gmail.com with ESMTPSA id a189sm8407228pfa.60.2019.08.16.17.20.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Aug 2019 17:20:48 -0700 (PDT)
Subject: Re: [Bug 204407] New: Bad page state in process Xorg
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>,
 Andrew Morton <akpm@linux-foundation.org>,
 bugzilla-daemon@bugzilla.kernel.org,
 Christian Koenig <christian.koenig@amd.com>, Huang Rui <ray.huang@amd.com>,
 David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
 Joerg Roedel <jroedel@suse.de>
References: <bug-204407-27@https.bugzilla.kernel.org/>
 <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
 <20190802203344.GD5597@bombadil.infradead.org>
 <1564780650.11067.50.camel@lca.pw>
 <20190802225939.GE5597@bombadil.infradead.org>
 <CA+i2_Dc-VrOUk8EVThwAE5HZ1-zFqONuW8Gojv+16UPsAqoM1Q@mail.gmail.com>
 <45258da8-2ce7-68c2-1ba0-84f6c0e634b1@suse.cz>
 <0287aace-fec1-d2d1-370f-657e80477717@vandrovec.name>
 <6a45a9b1-81ad-72c4-8f06-5d2cd87278ef@suse.cz>
From: Petr Vandrovec <petr@vandrovec.name>
Message-ID: <83927e78-4882-5c14-58f6-cf6933024645@vandrovec.name>
Date: Fri, 16 Aug 2019 17:20:45 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101
 PostboxApp/7.0.0b7
MIME-Version: 1.0
In-Reply-To: <6a45a9b1-81ad-72c4-8f06-5d2cd87278ef@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vlastimil Babka wrote on 8/16/2019 5:47 AM:
> On 8/15/19 9:13 PM, Petr Vandrovec wrote:
>> With iommu=3Doff disks are visible, but USB keyboard (and other USB
>> devices)=C2=A0does=C2=A0not=C2=A0work:
>=20
> I've been told iommu=3Dsoft might help.

Thanks.  I've rebuilt kernel without IOMMU.

Unfortunately I was not able to reproduce original problem with latest=20
kernel - neither with CMA nor without CMA.  System seems stable as a rock=
.

This is the change on which I've tried to reproduce it with your=20
debugging patches:

commit 41de59634046b19cd53a1983594a95135c656997 (HEAD -> master,=20
origin/master, origin/HEAD)
Merge: e22a97a2a85d 1ee1119d184b
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Wed Aug 14 15:29:53 2019 -0700

     Merge tag 'Wimplicit-fallthrough-5.3-rc5' of=20
git://git.kernel.org/pub/scm/linux/kernel/git/gustavoars/linux

						Petr

