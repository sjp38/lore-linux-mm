Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4BE0C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97F2A20693
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="BIdKKQ84"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97F2A20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF97F8E0008; Wed, 13 Mar 2019 01:21:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCEA08E0002; Wed, 13 Mar 2019 01:21:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A974E8E0008; Wed, 13 Mar 2019 01:21:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 84EF38E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:21:26 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 207so554658qkf.9
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 22:21:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5/G8rkra1PA9yXaI4RJCelywIsswxA8Yq4jhZqugh54=;
        b=EW+6x3Fc4FkuidvHHqKe2g9bGLA8c5zv2A7OR4zNWae4gM6v5IaiGLePo/U8YueZRm
         ksg2MDmzwip0LGozLFxUc78ZbI9Qo6AN92d3nwZW4HoZE7V5Bc0fTeN+4pFJeM90dHVg
         kywd312YH3PaoxS0vKzLpcbSzsiacU6rIzbQ3K2AasnOwqHoxvEae3tBOOo13xDwZv/y
         WUt8Q2qsfwiMK8u6UOJmy/LrdsjEczTjP1EMTZC+CGzgIeSvl5t2gUhXb3Ul7kn9qeQu
         s3//jTwSl6r6QQhuwf/TlTFw2zUST/M2kYP/Hf3qzVgCFNWVQpS8RNOm1WCAFUgGxoNs
         0KbQ==
X-Gm-Message-State: APjAAAVtXwMeY/5wIjJLE1DvZWp/cqXlIfwg8ZYiLnCpVYjNpebeywO7
	ofdD2Qi0mTd9TQxZz9lNPm8OmZ41u9rA9UXfAd/JFHrCzD0+TFul6eUxM+/WIPYxzpUCesPmQZZ
	O4yLK/ysD4THpR1j07J6T4QSlyZORTZR7fMCBPVQ1LGKKlzfriJpA4ZRqZOKFZbU=
X-Received: by 2002:a05:620a:122e:: with SMTP id v14mr31320800qkj.105.1552454486354;
        Tue, 12 Mar 2019 22:21:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3+aq8n2V0McjHO4GgV9cjxMzBfKFOjeZgZnYUNWNOc+oBDI9ztppwbLdB7btJE7NmWP2n
X-Received: by 2002:a05:620a:122e:: with SMTP id v14mr31320783qkj.105.1552454485725;
        Tue, 12 Mar 2019 22:21:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552454485; cv=none;
        d=google.com; s=arc-20160816;
        b=WHL8ASjLBrvus0Inlt7sKFBiwcyg0m143lM8KNMj/rr8KNzHgEjofpgNZTqc8yuDoy
         PRGXc5Oga39wmphmGbtTypOTM4u0okAiDzW0f0KsuIbyclmN+VF75WVdpAAgw93opPE7
         ztWxcDgMQKLsVtXeiv9ogjQenGS1qiHswQQjWKUvqRx94bd3dZFBIUBeuuT/R5lwkboC
         gyq9NPOKjO4rP95RsiaY3KdumGeOP4wXxZC9gnfE+jtvqMp2+3NtM4e5R1N4pAaBnWfu
         FEKAruzcS0FHEJYowKbDckwRNs1kaWjpx6cTMiWpe9IHzZ+8EDKV7/x1SITDEraoggiO
         jPNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5/G8rkra1PA9yXaI4RJCelywIsswxA8Yq4jhZqugh54=;
        b=aFmQgtw4apAjVZtX6FYZj4ZybVJ9Snd7jUwdOydbmqmuiGtEg6mzwF/dHjqWE1Xuwc
         lgF9n51pHg2zj7O+CcdSkv9GWmAwrrSNje5YAOZw1s1SxU3NVnu9Bz0WT4adqjR4RinY
         NQn7+OJmf084vDwokdhIeM11KjxwuZht5KAumJ6v6Xpi1n8teujCEfv2fwhyciRACCbO
         5/M7xf+Yc4MFZ4ftxDO52NqaAZwbKbJxeS+ThlozhqzQYGx204KIjl0iqGP7POm/7iOG
         EprrBxaB5ZFd8/w9i0H4LKZDhZuFhNypYmyxZQHnjIsMxWHDXfBOSppOxEt0lG1+5URB
         XL9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=BIdKKQ84;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id i17si2833834qvo.131.2019.03.12.22.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 22:21:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=BIdKKQ84;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 32C5F38BA;
	Wed, 13 Mar 2019 01:21:24 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 13 Mar 2019 01:21:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=5/G8rkra1PA9yXaI4RJCelywIsswxA8Yq4jhZqugh54=; b=BIdKKQ84
	puIE8JiP3C10giQIRAAGXWMTSyOOJZwUWGn+oYQuU5RbdWp3FcAaZzwKODB3mziB
	81SXV9l4IYnPWxoEtNI/QmGYbCxKyBMZ4QZx+UMMhBpc/Ky5OnKv+i8Jd3w9+Rl1
	wPSr6W+u+bgFYSbUTrxIuyTNqYzsPqo/7UMg49LDlIctpXQHMJRWKVAMea1ZtGRU
	2lsnNz1pqWSeH0rf+qch8GyvmjswpadElzUfIw/KPhS/Ug1EwzfekSvZtBwtpvpE
	Z2jxMNfqLlXFyiMemrWJ64aPSg4mgtYITFr+N4IKi7+Vcxhv/h/Cl5LaJsatiAtl
	ZK9+dauRWkZ0oQ==
X-ME-Sender: <xms:U5OIXEoAQJ0VZauhADwEbcpZSgcR_NoBYpG1TXBEQqjl04c56XBqUA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeelgdekudcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeeg
X-ME-Proxy: <xmx:U5OIXFGpU66pafwJGKzjwD7Yx2cytRviFezQqZjfb1BeuzqW0sB3-g>
    <xmx:U5OIXAtc1AqHZ6TW3e4bM3MAS1XB14Ajy7-zh88LE1l2aYdYauJqjA>
    <xmx:U5OIXDY0MUj11yd8rmDxVBmygK_7QN4lzGr1Ja6URIk6IrfwLW7Gfg>
    <xmx:U5OIXIP-QXHlaqcw74yAQS-1jj7C3ZgTf_I0aQpbGU5Z3PxAYfTVJQ>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 5BC0BE4580;
	Wed, 13 Mar 2019 01:21:20 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 5/5] mm: Remove stale comment from page struct
Date: Wed, 13 Mar 2019 16:20:30 +1100
Message-Id: <20190313052030.13392-6-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190313052030.13392-1-tobin@kernel.org>
References: <20190313052030.13392-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We now use the slab_list list_head instead of the lru list_head.  This
comment has become stale.

Remove stale comment from page struct slab_list list_head.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/mm_types.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7eade9132f02..63a34e3d7c29 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -103,7 +103,7 @@ struct page {
 		};
 		struct {	/* slab, slob and slub */
 			union {
-				struct list_head slab_list;	/* uses lru */
+				struct list_head slab_list;
 				struct {	/* Partial pages */
 					struct page *next;
 #ifdef CONFIG_64BIT
-- 
2.21.0

