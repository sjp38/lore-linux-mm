Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21D8FC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:18:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAE1921773
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:18:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAE1921773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C5FE6B000D; Tue, 16 Apr 2019 19:18:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74C6C6B000E; Tue, 16 Apr 2019 19:18:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EE866B0010; Tue, 16 Apr 2019 19:18:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8206B000D
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 19:18:43 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h69so14986687pfd.21
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 16:18:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xfM/1z169weS4o8gSVwlx6cjIBjijg4WDvogRtuwd1g=;
        b=lqJpjUUrXHwq7c5GeWBV0OIEYkyTTtWgHwr36KSq/JvrIgsVBFjiZQRg0rdk3E1tMR
         XVr+ewdEsYb48WnFdX67A//i0LMMpRMiDyuoA/G8O6o19qKFmfkvYQzSJeuvMvGgNXNo
         5FMGvb4Tzk8+4jGWsgm/qMkZ3fJmwm1oLqIEzfAKBbvHoQbu30QZYtXu1UA9pxxqr2Ee
         SHiPD6FZrbBsfiYO3/kFLcWW5yyaVdVq5Cs98r5mM71k81EjApqc520Pd2DVmKfyzAcS
         yw0WYf01EZnXIFHu8Zj7eT7VcLVwptS2SqcTggrUkCoHysJUWM+BN8fq3Bh7voav2ApP
         u2ZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAV/crRM+z/IF8yL7cRjPdMGfpw/t4chJdMY0CAu1pjwVSHmt5CP
	Tr/bKRBwwEzi8Nc6DZLfg7iVHk1eJczUKcu0+/HmECVEvrqSTkSYJDPgmQsSLFMpLt6IdcTKB90
	DqQaCZvj/VqW/P3/aPyH0mWApvv/Z+DT1lzofujg0naMl6DXKt+lGDtelrE673qC0dw==
X-Received: by 2002:a17:902:9341:: with SMTP id g1mr48086783plp.81.1555456722869;
        Tue, 16 Apr 2019 16:18:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRoN+yNUMCT7wXHyT4MPQ6OymSu5W4vaCs/avMWo4cK/PX+7yDv4sVPtkcx6K8AUGVy9/U
X-Received: by 2002:a17:902:9341:: with SMTP id g1mr48086734plp.81.1555456722100;
        Tue, 16 Apr 2019 16:18:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555456722; cv=none;
        d=google.com; s=arc-20160816;
        b=IJ6WXo0M/5F+EZrwN+zQv/Ne5N5vFQewtnmkfdwtcvneNJNqdMEsT0V53uvHITFMu7
         2OdG6ii5SWTnigfJdwKD/IHsTmNd1I+8jGSObNlTu5Wb2mXwvsRqA+9Ue4x/1136qqy+
         DF1foMFFhHd9Ids6v+XaT/ou8YXcCQEL4Lh7eEXq//o3lLJtn7Ott+cw8XQltp9dqExe
         r//X79I/OaFcoX7HACQ9z+RA3SIUUzmEsJhx5irmK23lGfR9JbyL9syMOp9av5/x7Uhx
         QdEbmvrFvl6syozQaTcJKjjZnrP9KMNinUdUw3cbPCYfFchdrisAigJdlxw99t1tUTiM
         8oPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=xfM/1z169weS4o8gSVwlx6cjIBjijg4WDvogRtuwd1g=;
        b=C26pW9MxK/cQl8YeNUZhdl80KzOg1shSzG6o1l9+sopBoYFwj5IyvZF/4A0bxK+8M2
         GF7S4HiduXeQNcLWwo3XYDIhUB/XtOoUjW24Dwul1/gU0BqeXUjCfLIsVma1kDFNTy/v
         MajAiMfiBKYmufXIuNgtG+OPHY7LTWL43ihBxkqZBOrnr/1mkk3TXLjKFfeYZZzTZOGt
         HWY3ttXNhw+VPMpY68Urw5rS6Pk2KaYDAa+QJycYAQMoH8mGCCE/noVKF7CAQJYThZ6m
         s9uP9hTPcY6cG2YPbjXbXpzTrSynyFd+IiwUbcyBy+xnDQt+Lur+c+umlcq16f8Wgfyi
         3Pjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v20si48780254pgn.105.2019.04.16.16.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 16:18:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 8A8BFD90;
	Tue, 16 Apr 2019 23:18:41 +0000 (UTC)
Date: Tue, 16 Apr 2019 16:18:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org,
 Oleksiy.Avramchenko@sony.com, Dan Streetman <ddstreet@ieee.org>
Subject: Re: [PATCH 0/4] z3fold: support page migration
Message-Id: <20190416161840.c54f8fce7557e24fe0922338@linux-foundation.org>
In-Reply-To: <b86e6a5e-44d6-2c1b-879e-54a1bc671ad3@gmail.com>
References: <b86e6a5e-44d6-2c1b-879e-54a1bc671ad3@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Apr 2019 17:32:12 +0200 Vitaly Wool <vitalywool@gmail.com> wrote:

> This patchset implements page migration support and slightly better
> buddy search. To implement page migration support, z3fold has to move
> away from the current scheme of handle encoding. i. e. stop encoding
> page address in handles. Instead, a small per-page structure is created
> which will contain actual addresses for z3fold objects, while pointers
> to fields of that structure will be used as handles.

Can you please help find a reviewer for this work?

For some reason I'm seeing a massive number of rejects when trying to
apply these.  It looks like your mail client performed some sort of
selective space-stuffing.  I suggest you email a patch to yourself,
check that the result applies properly.



