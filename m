Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6F87C169C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 00:57:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72FD320820
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 00:57:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="t7MNzljy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72FD320820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3D5A8E002C; Sun,  3 Feb 2019 19:57:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CECC38E001C; Sun,  3 Feb 2019 19:57:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C03EA8E002C; Sun,  3 Feb 2019 19:57:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9704F8E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 19:57:43 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id b187so5493706qkf.3
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 16:57:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=/ir7ml8F/rIYLqfkm9Jph1TAjuA2uenn+ZQNjGjtcNU=;
        b=sKT+sGGVwCwXRGjSbxxqIFqW56qKIvkccpCvbiObVXQlE05YNeMniR2q+VjNhIY7Kc
         g+j6g/S8HsWBPwO5KA4uLIjpCKvcnMBSLkkjEN7fKey8p8UvHnto3kzg1fH+qf2qJB1l
         wfCnQf+m5ND2zKgRNpNwwPPEK+cdLkz5LaaoBQAu3Q3r8ZP6uMbsNu9zxrCc8Y33MYeQ
         yAvxtcn/y4U8m9wRA67XQ+OE+U3UpaiFB4hiq55KKAQwCyBAkjO8neHF2AoiCkDpXnww
         yf0IEFtWxy8OUGmVT/QHRwxrsdohZXFN8AysZ8KhXGWrVH3YX8lup9rzTM66xiCEd32l
         pBQQ==
X-Gm-Message-State: AHQUAubQuoOdGpvkGVU/SOgN+2fFBUXg6ATKNRaCc6RV6q+sDHWUC1vB
	X+VFw3c+lfF6F86UnLOH892KEDDP1LlwBd2v8rKijkFGe2N3Rt371HomA7Hg6UIh60iFPdtEPbT
	ODJyqWtKzkwUdL7rOjAKSH0pZ5cbj+q1A/RBLsrHL2NLd19cyi3DQJEuhr/YA2k0=
X-Received: by 2002:ac8:110f:: with SMTP id c15mr160981qtj.355.1549241863326;
        Sun, 03 Feb 2019 16:57:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaUTF3aib5wvy0bhcuSxYWdDlKwidEPyQ8bv9BubcOSeOsbV1OT/o5ivx+nIQ0nijcrIfRG
X-Received: by 2002:ac8:110f:: with SMTP id c15mr160959qtj.355.1549241862632;
        Sun, 03 Feb 2019 16:57:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549241862; cv=none;
        d=google.com; s=arc-20160816;
        b=igTIePyi86gxGuu0LgkPo2mT7LIUHsXJ0Ov7q9ZYgclZMMEIMQ+/d/pWTUsOb+5QGe
         WnFNTsi9+7A0nu+JySHWstrZ8JKSoP6r+LJYWoQhnBFbAqmCrPoISU/Zd4mCmlOyfFk/
         gWBuXWSsNNV2z7hbG3nRwo0ietcpj/g3yBWlOA8jQfe/l/8t6T/9xCU6Ts4iTQwwFBhH
         fVahnfS9cPyo0qHc6TBOYvvKlioMmfcJrkAmLEHiK7sLlMNGmVcjqi8cu5eQAHFnbZId
         g+4PpJLKEi+TBB4thywbK7JoHCQqiKYNmEiHRQeetQt5KVmdVQ28zZ8dDNdQGesZDz4Y
         B7XQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=/ir7ml8F/rIYLqfkm9Jph1TAjuA2uenn+ZQNjGjtcNU=;
        b=dTbxw7LUyb0QFRuOuwJnBU9NxAh+bAcNVKePND+GcNMr9VTLhHD1pYGK3ELchQDWcb
         PykNjWtAagNiKA6e8w8uubECOq3sELKsi+q9XAM1UJ456Nl8B1N+Y2OFynZqACc8OgvX
         XiCZDEOs/5wgny7XD4OEzmlYBMR2cqhKKrs/gZxx+nW3IPShEteM8HPLyC1KY7WcJ1iS
         lGTTHQei6qBfJ8rV+RXkh81cIIdNW1i8D5TzxeSBPNHEfzq+LB4byHX2Ik3gGVLMFZhw
         O0s0xHtZlBc/XQX2PsiNkixSP7dLdANxnR5WzjtK1bWeaAiolYu0Ac1U6bVkco1SjB30
         43fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=t7MNzljy;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id x39si1810944qtx.402.2019.02.03.16.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 16:57:42 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=t7MNzljy;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 2E47821F99;
	Sun,  3 Feb 2019 19:57:42 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Sun, 03 Feb 2019 19:57:42 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=/ir7ml8F/rIYLqfkm
	9Jph1TAjuA2uenn+ZQNjGjtcNU=; b=t7MNzljy/yEunoZpuhZZEoubaVkuiag2i
	NYcbFZB+Ffe7jh2qmWcKJQL5Zs1ryp++41Pa73wjGEPc7crElXE2NfirQ64h2mx2
	87/d7Hno9L48rD9D2pnuDsO3slS607+STuk32xRqNA4nUyeOtakawXfNqX8ZY/00
	J4CstaqQttz3hm1n2MYM1UYGWa25Mf//pZ815ln2Jhb+go+pEHT8TiGnaV50Kyyt
	OhKm863VQ1L/06L9pCrZsZIkMZ0/J3W7RQtYeECjxMK2Ven0gDzKFLJmQqBOiOvp
	1HfymtkVRkGwBbXB/f1kePivg3bcU9BB7+88P5MbS2qqI915Xk4+Q==
X-ME-Sender: <xms:BI5XXNpQJ3lhDN9eejiI8ws69zDyPaVMbb8Sp0wTyZxk3ibWhXGhFg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeefgddvjecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkffogg
    fgsedtkeertdertddtnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcu
    oehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukfhppeduvddurdeggedrvddvjedrud
    ehjeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghinheskhgvrhhnvghlrdhorhhg
    necuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:BI5XXC5R17GzisinsJlTD1aS1r2EB0ohyObNwW7aZWNn0_ZMOkPByQ>
    <xmx:BI5XXDpoz84tXD102xmZxbXX6BjeJH8X7JdoKcsEP7DYHz34n0AQfw>
    <xmx:BI5XXEj4zDE1VFRiNeVJcoNQloME4ua7nMkRA0gNik53vRinNuUy9A>
    <xmx:Bo5XXAeAiqQAWgxqsqWbIfJOK7rptciyBjJx8koLW73z0Z-oeNOnsw>
Received: from eros.localdomain (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id E8E4D1030F;
	Sun,  3 Feb 2019 19:57:36 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	William Kucharski <william.kucharski@oracle.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 0/3] slub: Do trivial comments fixes
Date: Mon,  4 Feb 2019 11:57:10 +1100
Message-Id: <20190204005713.9463-1-tobin@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Here is v2 of the comments fixes [to single SLUB header file].


thanks,
Tobin.


Changes since v1:

 - Re-order patches (put the easy acceptable ones from v1 first).
 - Do grammar/punctuation fixes thoroughly (thanks William).
 - Send the set to Andrew instead of Christopher since we are going in
   through his tree.

Tobin C. Harding (3):
  slub: Capitialize comment string
  slub: Use C89 comment style
  slub: Correct grammar/punctuation in comments

 include/linux/slub_def.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

-- 
2.20.1

