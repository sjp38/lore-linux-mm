Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2304AC282CC
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 06:43:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9B312080D
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 06:43:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Z3u5lxBR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9B312080D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 171E68E0076; Tue,  5 Feb 2019 01:43:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1215E8E001C; Tue,  5 Feb 2019 01:43:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00FB68E0076; Tue,  5 Feb 2019 01:43:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F55F8E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 01:43:39 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id r16so816222wmh.7
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 22:43:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cvt1gBX8WugZ91yn9owVv40hdROA38XCFOkwQHyD13c=;
        b=E2E3XI921mGQXPeCwTNWblGXCgb0D6wmXOWfAC/bUW1rqac1YWNO2wdvpckUlM8XyW
         o+OL9kGDz/TOVBuncDwriDu2Wllv5Qo7B28XnMhp3NonWhz8ID8V8wSszonhgFn8xvXX
         Np6zJyDSPRpBqERQgYbbvHSqrHGtCzM1RDLspbQC/uwZbzEnk/Qr7XsDpVp+kSOM3uC8
         tA755r9fDOIpI8fZIJsxWX1R5M6BC1LH6n6lm6JOAy8OgyeXWtlMhJBUiwLxWu853bzo
         okl08yb51HNd075x9xbvolE9MDLiyGBmgl0cpvFZbK29cf7of2/U5J64GzwY+EI7v2jL
         mcBA==
X-Gm-Message-State: AHQUAubP4rvXI+InwFws3M+9AdgxcUlcwjKtDIKDWjL4d1BgZqYRfKL0
	FDhdYOnczBMxVLIPIKexV3vPJVv7yar1sFQ9o1dCqROQYCGODzpHkJalwo/3bYw7grN0tLPvqqL
	LJUlp4fr5nz2SAVCafZJBAYEV0hJ+wJCnKvUJL5NRxR9vQQsOPxIAYIbsXB/gFQeQEWHzVCGrQK
	Pg8NUCA36S8qs+jTZfohct3nyT7WqHDO547tN61QVv2dHjNF18/BoapReNt/MHGkdDOVGYcnzJm
	zb31zjbyPzxJEsxTpIVPGEbD+OeDx/QP5Dxtg/na8WdfHhP48b0NeWPWAEEbyqQQ9PMhEGyip2d
	eB21+EmRsu4v3l59hYLqHb/spuoi9h2Ezz6NyEpJhjp4euyKymdyjVr+tbkwwBQOUHXuqTSdQXB
	n
X-Received: by 2002:adf:f785:: with SMTP id q5mr2375646wrp.9.1549349018898;
        Mon, 04 Feb 2019 22:43:38 -0800 (PST)
X-Received: by 2002:adf:f785:: with SMTP id q5mr2375598wrp.9.1549349017950;
        Mon, 04 Feb 2019 22:43:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549349017; cv=none;
        d=google.com; s=arc-20160816;
        b=A3qTv1Ss30hcUERMolwBFJCVcZFGkW1bgqnLAeJPhwfYZOa2dKjfSJ/4zXhPpQnWXx
         v9D+M3UpVbOu7xAGLSkqvC2SKYmWarT0EBR6KKOcZA0TIGyTF9PUjKgU04XrwEHV4G4T
         +ZQN3rPXkn4NuP/RzRYdMxif+E9VuLGu6VHRPTZf4A/N5QgyUTdMnRFfz7BgdU0wlGs/
         R2PM6fP8+ludMt7k/mU9gSgg9lmPuBAV44E7mDaClCgvj3/xVFolXF2BYnyhSEQJne+K
         gCX13xQanFYRfZrOqjtJesW38yww8m2OGtAAjc8E8ymAmJ6UVNZymdj9Fpq+G7m60XXI
         10dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cvt1gBX8WugZ91yn9owVv40hdROA38XCFOkwQHyD13c=;
        b=CW3WatHjfsvx3YQNP3Rdrg0IMgNoklWXCc8O/8ysSAQiczIZWA5byS9FL3CGgRs0wv
         1xCdTseohiDoS5xETACqAUzf3zxZaVs+ZZMIFFGjCOzdGIeBv2kv2inTFn7pFRH5BBGh
         1vza/SOqAVvC69KsXQR/A36ecKJ5KBP7cLEtnZNft3nk1e6mYSaPwdwCGcw/8i3O7Ofa
         bcWaW+QE/DeJDTlRXRRr/4TDacXg2ImHwR78SjA4GfIxliux19BBgA9nokhKo+zNTNMs
         edzlTL6LX0eDjJ9wdfytuwieoTwrzdttx0AwlWWqa3edom+rIn+qMCoemfwXyW/qB/Xz
         /VeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Z3u5lxBR;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i4sor11792150wrx.38.2019.02.04.22.43.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 22:43:37 -0800 (PST)
Received-SPF: pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Z3u5lxBR;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cvt1gBX8WugZ91yn9owVv40hdROA38XCFOkwQHyD13c=;
        b=Z3u5lxBRCB1CtcyB28C8/R6pCs/O5Gxt4YvM/+tVHicyFBoiMTKmW0Zt3NIYb6I+4h
         iRj4dtN6Fz2vYla8jJ3L37lM3VeHrPC8O43YR27SS88THJJG7t7yjz5cQ+3QPpYTzNXb
         P7jGDOFmnlhr9rF10N0aNqELj2VApJ5PePI3zvfVQz86GeMHJYtAr8rCJVZ01SV1EiNZ
         5SOtJKosQn6ra86M6xhr4t318ymQP04Gu1pgYibTAaE9jUPMcD+nJUaNoFKnZYbsjnnk
         YgpU+IE/v6a0kabUfL0UwV6B+IYPB/urZwFhtse9kscHWl0DqYKTP4M1sqWKCqk1pVzx
         V1Gg==
X-Google-Smtp-Source: AHgI3IZP9z8nEicnVGORS3TkzJFsGYkKRQmvAKQwTvuWZjW0uUixchVu8ulhFrcqiBe0MLUJ3nsDcw==
X-Received: by 2002:a5d:4e08:: with SMTP id p8mr2358679wrt.235.1549349017459;
        Mon, 04 Feb 2019 22:43:37 -0800 (PST)
Received: from avx2 ([46.53.243.91])
        by smtp.gmail.com with ESMTPSA id 129sm24049450wmd.18.2019.02.04.22.43.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 22:43:36 -0800 (PST)
Date: Tue, 5 Feb 2019 09:43:34 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org,
	Richard Weinberger <richard@nod.at>
Subject: [PATCH -mm] elf: fixup compilation
Message-ID: <20190205064334.GA2152@avx2>
References: <20190205014806.rQcAx%akpm@linux-foundation.org>
 <08a894b1-66f6-19bf-67be-c9b7b1b01126@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <08a894b1-66f6-19bf-67be-c9b7b1b01126@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

	fold into elf-use-list_for_each_entry.patch

 fs/binfmt_elf.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -2110,8 +2110,8 @@ static int write_note_info(struct elf_note_info *info,
 
 	/* write out the thread status notes section */
 	list_for_each_entry(ets, &info->thread_list, list) {
-		for (i = 0; i < tmp->num_notes; i++)
-			if (!writenote(&tmp->notes[i], cprm))
+		for (i = 0; i < ets->num_notes; i++)
+			if (!writenote(&ets->notes[i], cprm))
 				return 0;
 	}
 

