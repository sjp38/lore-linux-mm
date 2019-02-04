Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CBD4C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:04:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 329712070B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:04:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 329712070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B087B8E0065; Mon,  4 Feb 2019 18:04:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB7268E001C; Mon,  4 Feb 2019 18:04:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CEEA8E0065; Mon,  4 Feb 2019 18:04:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAF18E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 18:04:13 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s27so923539pgm.4
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 15:04:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YGTF/GPVpY8M/HQ+Lclk8fkCIbD4OJ7byb+Cl4Vks3Y=;
        b=XsAXr7sjh9RdJ0FdfNzQy/3SYjy+ly/mJlRZ6/uz21XghSzujwU0tw5s/EEDMN0zDl
         +K7zx3DNZTJpygDuOBYXfgHWbm2zTO9lUp9+3VrYYUEHlP6C42wfw8DnAu+xQ6nz/qI9
         gb/W+UEA6y9ol1Mr4fkIoN/kgY2LmuF/4p0IgeUiSUuCJi/FAjXaxQVAKmzZ5MJaVp/r
         j33asyK1Ul5q+wVqYRx8KsdU5L8d6otoCbyhWUdtTweiXANhurvJZCG06kys4QYxEkUg
         S9ef1w8PVfQonA/NkhXtJzpHj+FlweU/tLBtfJK9ax3DwHZTNaOwSU0tnB5B+ftLhihO
         j4kQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuZ+QMMQXM9ba5IDlnbnMsxHU39F5f1L5Csysoy3r5OSDIJfBOEv
	kfaSM27Yx4/FaIX6z17/6RfNVUWSmhOaPWtx9R8iViKswDtW67hkXV1+mcYzor62+NCr72ziK24
	arlXNUIUaR76NDwYMHz19V8/haii7T8K+5y9I2jgF1jEgf9t/hDjOjloVb3W4BNCAdQ==
X-Received: by 2002:a63:cd14:: with SMTP id i20mr1685784pgg.288.1549321453106;
        Mon, 04 Feb 2019 15:04:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbpABm8ggpVQqNiFxZODwdsKXmV3r1K5jYpqStivvZLyPO/wCbYxo7wtac1O75+70J5M35x
X-Received: by 2002:a63:cd14:: with SMTP id i20mr1685740pgg.288.1549321452414;
        Mon, 04 Feb 2019 15:04:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549321452; cv=none;
        d=google.com; s=arc-20160816;
        b=w2CQW9HoUpSl3HN+rLpIIP6cvu85eRTFZR+jjnNh51nnrB8WDwVlUTALMdY+IOWU/M
         WqIvB2LhnVgT9xVIuqxd8uLTyk7cZgKh5P4peS2au75+IaNfmTy5Mi5zMpBSPUjuUm9d
         0ip81qw3Yn89Ay/HlZZyE15rGsr3/rI3gopvbctwtb90RgAKMo00wyJMp1L1loT14FWM
         LFEH5C6ZtErlHAtcOHfNNXZ4IGfTVkQ1rdeHUuKrxDeV5e7z+tZJyPcvg+LC7sE1dB1+
         pb/5/Xn1xvpKCEU5JhAvKYuvk4/sxSf+kZPOlLpXdFxu3k9N0H9QktufbRxi7Yfx87D/
         dxwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=YGTF/GPVpY8M/HQ+Lclk8fkCIbD4OJ7byb+Cl4Vks3Y=;
        b=khUz0sjFyRVQQUJHvSU+ls7zzVN8yurLIGXSOFOdnyj1fz55BxqdGXXHW6mHDp2IdD
         xRX5nmcybpfbngtsArxOqAlcxmOSHH6yEDvrlYE9V723J3iKg2noXCwFQt9pkYMVcQeJ
         2DeXImJ3Ll4S7r7J1ii+e8SF0XI96plaUnRRBwRcupv0o+e/Z+L79IJupKqY+pctBsIO
         D+YF5YEfYPYhHGv1HPMkA0OBOELFQUcpFiNxyXvP9ZFXt2QliwfFGMFjvsAvjdNjKXDA
         uBPPLoX5fC/SnjB3EBH4WkABmAsNUisCt05qXMRwiPzHg0avO3J+zj4/Ayn3GwiQv82g
         7z4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m187si1368697pfm.51.2019.02.04.15.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 15:04:12 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (c-24-6-103-156.hsd1.ca.comcast.net [24.6.103.156])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id BD0FC986E;
	Mon,  4 Feb 2019 23:04:11 +0000 (UTC)
Date: Mon, 4 Feb 2019 15:04:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christopher Lameter <cl@linux.com>,
 William Kucharski <william.kucharski@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/3] slub: Do trivial comments fixes
Message-Id: <20190204150410.f6975adaddfeb638c9f21580@linux-foundation.org>
In-Reply-To: <20190204005713.9463-1-tobin@kernel.org>
References: <20190204005713.9463-1-tobin@kernel.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon,  4 Feb 2019 11:57:10 +1100 "Tobin C. Harding" <tobin@kernel.org> wrote:

> Here is v2 of the comments fixes [to single SLUB header file]

Thanks. I think I'll put these into a single patch.

