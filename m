Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81548C0650F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A8BA20C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A8BA20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C6346B000C; Mon,  5 Aug 2019 21:48:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 976E86B000D; Mon,  5 Aug 2019 21:48:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 865A76B000E; Mon,  5 Aug 2019 21:48:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50DCB6B000C
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 21:48:46 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r142so54694863pfc.2
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 18:48:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=6/Aip6bUWCQSKl4SGqrErkklrNRbedzA7QbqABMotG0=;
        b=FYWFWfOx5EOr+fgQdh7F9jJnvESQVGDYoXtf97rP3YYzggUzGCzQa1H2l1209PXzvW
         f8mUpY5YLOymq0QgnIuU6lnHTvWbaUlVPeYVGwVYJL1/b7lTJUwnoxe4poXoPo1zOkSu
         6Qvc9+dHf1ofP7CHi01WVGKTNV8+fCODF8nvSOldNVse7Gs9ngLa3vF8eQxvoZ9mud0H
         j0rtLFCCpOK04jg4ncD1ezQq8hcwL5lLvzdMY0DobO1twkVhhUT4eWH6eTPg/YWQzJnJ
         9L24jrOyBVQCKTg4/+gkAKc+F3hyqov5gJaeyvD8U037LTlNTlV+8uGfaU92Nq775wA8
         6oaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAUQZ2feyZ2k890uFupAxUfogGDiCwEDjI4Yr9ONI26NPqhvd5uA
	c1EwuOaMVXmmko6V72fU7uH5ZjXUzLWw07WX+j+bDHc78gMCP5muVMZR7hhCAE0tqWcWz9Mbqrr
	QbtfY+0uvDTTrE8kP1WqeYvkiHQ3+InmWv58cLRNlmx0r8ox7lhZTZ5yBLGghYlPulw==
X-Received: by 2002:aa7:96ad:: with SMTP id g13mr1059274pfk.182.1565056126006;
        Mon, 05 Aug 2019 18:48:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRnfamerLuUdTQmz2qQk+VbXrXLaRFgqpcE6rnnqiZ8/54+qWTAdq04S5w4EgmT+SMhe2d
X-Received: by 2002:aa7:96ad:: with SMTP id g13mr1059223pfk.182.1565056125037;
        Mon, 05 Aug 2019 18:48:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565056125; cv=none;
        d=google.com; s=arc-20160816;
        b=UgAb0KOfn4Sh519LO7iE+IdVtHNkQPAZihV7Cu92l7lB/zDoFlaFjHZAkIa076yg5f
         km+BdcY54LtSu4a8N1J0A30bmNJtiwk/iW15173lLOsY6vJ8oWO9ec+i02yar+rCdAKH
         pclCrqw+o9v0lS0e1IK5WxSSRV20w6fNIgbcsWQbahY1ON5LGO8XjLDQKKjAml9+Y9IQ
         8CbFFJPy5NS67U4+CR/TmpI6cujVCdrS746wWUmZsMHuA9QLZrmnoOq7hNKpZ0HZr79v
         ERTz7kElQIMyU0Ac9uAXXBG87yPZzyh3J9uj/JxagtfnXsQkC89iQ4pvkQUyhM6r02dL
         dANQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=6/Aip6bUWCQSKl4SGqrErkklrNRbedzA7QbqABMotG0=;
        b=FtL+PlkKmi/yL81SmZAk1W6AoV3aCFb8yNFlP1sjbX+dy2mrtUSRbJEN5VoCa7NygM
         Ed1Ll4MLpcC123Y0T0Yb9nZoULAm2F9mhPf5jSbbRd2EhzSRF9uuFIpJ2LvkXLc+OsqK
         hgUUHutNNbRTNZmhGLP+rt6stnh+rvE/JyX3rE8J2+ES3T4N4WeNGhXPWbuz8QpiGvDC
         IgNgJQ/D8JeQ7uHqEHPc59TZ0j32bvIPnxahs1eQkFQdA80k02gWjDxZdvSyte9Yv/wW
         Y1+SfhYTu3GsCVX9QNqqzG3QqYdtBmJFBSFcbYrBAK7WtA2Dz1QL1SaerJVeHgq8hg9q
         fy/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-166.sinamail.sina.com.cn (mail3-166.sinamail.sina.com.cn. [202.108.3.166])
        by mx.google.com with SMTP id a1si22915729pgh.570.2019.08.05.18.48.44
        for <linux-mm@kvack.org>;
        Mon, 05 Aug 2019 18:48:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) client-ip=202.108.3.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([124.64.0.239])
	by sina.com with ESMTP
	id 5D48DC7900005FDB; Tue, 6 Aug 2019 09:48:43 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 35122045091671
From: Hillf Danton <hdanton@sina.com>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Dave Airlie <airlied@gmail.com>,
	"Deucher, Alexander" <Alexander.Deucher@amd.com>,
	"Koenig, Christian" <Christian.Koenig@amd.com>,
	Harry Wentland <harry.wentland@amd.com>,
	amd-gfx list <amd-gfx@lists.freedesktop.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	dri-devel <dri-devel@lists.freedesktop.org>
Subject: Re: The issue with page allocation 5.3 rc1-rc2 (seems drm culprit here)
Date: Tue,  6 Aug 2019 09:48:30 +0800
Message-Id: <20190806014830.7424-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 6 Aug 2019 01:15:01 +0800 Mikhail Gavrilov wrote:
>
> Unfortunately couldn't check this patch because, with the patch, the
> kernel did not compile.
> Here is compile error messages:
>
> drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c: In function
> 'dc_create_state':
> drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c:1178:13: error:
> implicit declaration of function 'kvzalloc'; did you mean 'kzalloc'?
> [-Werror=implicit-function-declaration]
>  1178 |   context = kvzalloc(sizeof(struct dc_state),
>       |             ^~~~~~~~
>       |             kzalloc
> drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c:1178:11: warning:
> assignment to 'struct dc_state *' from 'int' makes pointer from
> integer without a cast [-Wint-conversion]
>  1178 |   context = kvzalloc(sizeof(struct dc_state),
>       |           ^
> drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c: In function 'dc_copy_state':
> drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c:1203:13: error:
> implicit declaration of function 'kvmalloc'; did you mean 'kmalloc'?
> [-Werror=implicit-function-declaration]
>  1203 |   new_ctx = kvmalloc(sizeof(*new_ctx), GFP_KERNEL);
>       |             ^~~~~~~~
>       |             kmalloc
> drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c:1203:11: warning:
> assignment to 'struct dc_state *' from 'int' makes pointer from
> integer without a cast [-Wint-conversion]
>  1203 |   new_ctx = kvmalloc(sizeof(*new_ctx), GFP_KERNEL);
>       |           ^
> drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c: In function 'dc_state_free':
> drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c:1242:2: error:
> implicit declaration of function 'kvfree'; did you mean 'kzfree'?
> [-Werror=implicit-function-declaration]
>  1242 |  kvfree(context);
>       |  ^~~~~~
>       |  kzfree
> cc1: some warnings being treated as errors
> make[4]: *** [scripts/Makefile.build:274:
> drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.o] Error 1
> make[4]: *** Waiting for unfinished jobs....
> make[3]: *** [scripts/Makefile.build:490: drivers/gpu/drm/amd/amdgpu] Error 2
> make[3]: *** Waiting for unfinished jobs....
> make: *** [Makefile:1084: drivers] Error 2

My bad, respin with one header file added.

Hillf
-----8<---

--- a/drivers/gpu/drm/amd/display/dc/core/dc.c
+++ b/drivers/gpu/drm/amd/display/dc/core/dc.c
@@ -23,6 +23,7 @@
  */

 #include <linux/slab.h>
+#include <linux/mm.h>

 #include "dm_services.h"

@@ -1174,8 +1175,12 @@ struct dc_state *dc_create_state(struct
 	struct dc_state *context = kzalloc(sizeof(struct dc_state),
 					   GFP_KERNEL);

-	if (!context)
-		return NULL;
+	if (!context) {
+		context = kvzalloc(sizeof(struct dc_state),
+					   GFP_KERNEL);
+		if (!context)
+			return NULL;
+	}
 	/* Each context must have their own instance of VBA and in order to
 	 * initialize and obtain IP and SOC the base DML instance from DC is
 	 * initially copied into every context
@@ -1195,8 +1200,13 @@ struct dc_state *dc_copy_state(struct dc
 	struct dc_state *new_ctx = kmemdup(src_ctx,
 			sizeof(struct dc_state), GFP_KERNEL);

-	if (!new_ctx)
-		return NULL;
+	if (!new_ctx) {
+		new_ctx = kvmalloc(sizeof(*new_ctx), GFP_KERNEL);
+		if (new_ctx)
+			*new_ctx = *src_ctx;
+		else
+			return NULL;
+	}

 	for (i = 0; i < MAX_PIPES; i++) {
 			struct pipe_ctx *cur_pipe = &new_ctx->res_ctx.pipe_ctx[i];
@@ -1230,7 +1240,7 @@ static void dc_state_free(struct kref *k
 {
 	struct dc_state *context = container_of(kref, struct dc_state, refcount);
 	dc_resource_state_destruct(context);
-	kfree(context);
+	kvfree(context);
 }

 void dc_release_state(struct dc_state *context)
--

