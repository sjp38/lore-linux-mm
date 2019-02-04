Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC812C169C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 00:57:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA2FE20820
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 00:57:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="UZ9x1OHM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA2FE20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59B958E002E; Sun,  3 Feb 2019 19:57:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54B648E001C; Sun,  3 Feb 2019 19:57:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43DCC8E002E; Sun,  3 Feb 2019 19:57:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1506B8E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 19:57:50 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w15so17095129qtk.19
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 16:57:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vcmHXuO0fiNhzPIXwjvNEwttdZPxTbfquzDsHc95XIY=;
        b=kPFWsCpW7TWQx/q1x7Wd5zA7Jcn7tTk+LCRyfN2ngJshtyYDLWImG8NYmJswOVV8yC
         jom4RSCb1AhGjvv3eetrMcehruKDYY3dGIyMCS5XN8apn5gI41vbGqwje/WpvywYE7BI
         GUCvSmU4nHUAvFuv0WFEgZ2BwdeXTHrSEwz2iNEFWM/wRxAVT0Fws67kqBXZhrTtNocT
         LuzEA7KkQiSSJZOVWufDaAr4jqYs5KMeISB5svJ91kJcT7W2s+LapA/peEAfjw3BwZdz
         A+610VghI440NF90lPhXrBFdbecTfsNXhe9G8nYaLqWli3u8sTSVdKDfvZ73raYwJkSS
         bE8g==
X-Gm-Message-State: AJcUukc2aVAqDo57yQVIQWKqNwXYtxoM+0xO6WJQfUlbUX16bWeB8/Pn
	oyQV1jAtjfuM2X8cMdbu2IWnxaO8YXm4P5/MT2Gf4KB77nxHgjB0dRl4ZdC5PlBEPvGaLUGEA23
	kqaWVb+VRlJNjT2vEtKHPK57MAof3kB4UAnxKY7eiQUosAtYwDk6E5WEbLVNi+ec=
X-Received: by 2002:a37:ba06:: with SMTP id k6mr45165407qkf.115.1549241869843;
        Sun, 03 Feb 2019 16:57:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4gW0ejNjO9Q69Wysd01TbSyR5etlTkUAGqW+nsmBaAIgm1gxC/4jDp9JaBxdup9gkl321t
X-Received: by 2002:a37:ba06:: with SMTP id k6mr45165390qkf.115.1549241869261;
        Sun, 03 Feb 2019 16:57:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549241869; cv=none;
        d=google.com; s=arc-20160816;
        b=ffFRPOfqj2CyEx4AspTOdamlpJW62LRocmvfQYXipMxwkhJdHvNqdTQpX1ggj2GvX6
         4dD6nF+iUFtkDGerUtCsUTV4Iiika9oEhyIviFzcQF92HH57WYeWtGjIpON3d+maYjha
         DPhH2ZzOF3dXyxAqj/LAFyConH4YvBdmNc2Ho2E/wYX7/ss6mxpjsYf8HWPt4BDG1amJ
         GVew3eGnXRHoF3OGWQpptyv/kBtIcTSHuiNjL3CsD6jHKeYQHuwlR5RlfPFmdMwMs+yc
         l2wLj2hc4uMoDSimtf/h/SyJiglamOKk774GTaAPHzAkWPo+DQ9Sthhai0UPcCf2Cy27
         mpZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vcmHXuO0fiNhzPIXwjvNEwttdZPxTbfquzDsHc95XIY=;
        b=eZkZAC537kWpxGKGjIsMqrUCFWIlnn4wY/RMjSRCwj9q6kAaOD+Y2GRVAyJhqGsGMz
         jYHaZ0jSK/FImaOlOVC0Calj4ipHdei4HriA1H+2Ci2VIKw4kgglUgg2i2ghKSQ+ax1M
         Z3JDz34G5DT7xrgawNQLRoYbciH8tX8LvbKmp5uHvopuvjxTtQ2T/IqxRL1AIF0VlM0d
         ScOJWyfBLqaT6RAkl488yvzySxpE55jT3JEO6RD1YoJ4y0rT5abDdx0M6jM5tQk0G39E
         SI04sOydqnlBXU8Lb5TBlY5i9xb0RwGrpUo78+RcvXoLQ01nP/+mGpkdi1vCeyaPj8JR
         +8DA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=UZ9x1OHM;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id i3si173525qtj.108.2019.02.03.16.57.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 16:57:49 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=UZ9x1OHM;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 0A8FA20EA9;
	Sun,  3 Feb 2019 19:57:49 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Sun, 03 Feb 2019 19:57:49 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm1; bh=vcmHXuO0fiNhzPIXwjvNEwttdZPxTbfquzDsHc95XIY=; b=UZ9x1OHM
	MYVHu9XvtfawVtIousvWePSJIVavhprQBTEDBg4XVN0AvJNk8+gFxufbmQSqQ984
	nO50vy6j299jEYQz1oXMAUgp7Y0v1W5ycvb0R8/mGXwtGJsaZGAO6LkY86Rub/n6
	4tH1qHKDAQlIwQY6ZEUzhlXpIGOo9oeUVEJSFz8Jim9Dnx24bg75lxVC0OV3G95s
	Jc1SiA/lB7iUHO4YyW1fVAT0U5r+umLPcKhD/xXJMm9ejomgTrZoIz53BV0pxtdO
	ZI4cLtsFRPpramU+gDYtlfDtv64CgRuzS4UK0MMyKQ5WHJwasb1EUG7QRZjVxFEc
	tFMg4YUGzF4TmA==
X-ME-Sender: <xms:DI5XXJr4Dl1KfoCMbRarZSDSp6u1H5C2IclaVgQoNi71gRvpcl52Iw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeefgddvjecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkffojg
    hfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhg
    fdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukfhppeduvddurdeggedrvddvje
    drudehjeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghinheskhgvrhhnvghlrdho
    rhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:DI5XXCk3Rca7k4ilHQugsiRGTgbFRtu7jMN9LUAJlSyijmMtAFKyCw>
    <xmx:DI5XXMr9k44PaEhQXQu6Et3d5osCbCK1bWHosx2NjOLV-CKofI47Rg>
    <xmx:DI5XXDaUsQ75d8SPPJxTUbtMSjBgbFkEx6q69UP0lqh2T6-hnRzsRQ>
    <xmx:DY5XXDqG_eeQF_GT9pX_Khv1vzrp8CAireSWiAVFlRIpVTz4qtYP-A>
Received: from eros.localdomain (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id 8223110317;
	Sun,  3 Feb 2019 19:57:45 -0500 (EST)
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
Subject: [PATCH v2 2/3] slub: Use C89 comment style
Date: Mon,  4 Feb 2019 11:57:12 +1100
Message-Id: <20190204005713.9463-3-tobin@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190204005713.9463-1-tobin@kernel.org>
References: <20190204005713.9463-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SLUB include file uses a c99 comment style.  In line with the rest of
the kernel lets use c89 comment style.

Use C89 comment style.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/slub_def.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 541b082ffcaf..a3f1fc7e52a6 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -151,7 +151,7 @@ struct kmem_cache {
 #else
 #define slub_cpu_partial(s)		(0)
 #define slub_set_cpu_partial(s, n)
-#endif // CONFIG_SLUB_CPU_PARTIAL
+#endif /* CONFIG_SLUB_CPU_PARTIAL */
 
 #ifdef CONFIG_SYSFS
 #define SLAB_SUPPORTS_SYSFS
-- 
2.20.1

