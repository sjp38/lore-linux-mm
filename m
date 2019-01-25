Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30204C282C6
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 18:44:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6DDC218CD
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 18:44:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="OWTKgxsR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6DDC218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 833BD8E00DF; Fri, 25 Jan 2019 13:44:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E4E28E00BD; Fri, 25 Jan 2019 13:44:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F8F98E00DF; Fri, 25 Jan 2019 13:44:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 40EC48E00BD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:44:57 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id y139so3874247vsc.14
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 10:44:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mgiQ1AS1vbH52Fdhlzx0yBS0Qcj/v4CjMVy9B7SV8gQ=;
        b=iIQCfZVVZCJbaZwpWUAJSoFD/Wy2E4sUI+0ZHEqWOOAJ7ZWeFjbZTje45mngV3B0Om
         baWAHeLkGUyyxFC5z1sDsSnTjK7aUwBrdiCdcqzKCE7qG6S/bErzGdgkMu5PBg5L4Uok
         3YZCf6ridi2Mgo/tOZE6ls3D7KsTSgBBLDQNnRGuH6Nb9puHAWLiDub2UR+BxbhhlLjs
         oQsIHcLLuY5W5XRQ3J2ztZK+wFddKwut6yyQ+TBZD8YS1OJH+roApIFfitRPwGMvp0Ct
         2AYDi+PRTJBc3uUh+A7QxKHGphOaWpHyySxYEo2ujSggoqNbJpy8wyaSyXf4nF/I1bkW
         Xizw==
X-Gm-Message-State: AJcUukc+A5vAlTDkLy0YgtH6BHv/sJ/h+PkDrQZtGykhxyjYziFwX11i
	jvQaiorH+Wovu75VJ6kQeWqa6w8107a4exAIDHplxMYEVK/bXuhuu53LiijlrnGtLZOh1EtcqaV
	JbpHeFz6zhug/AQ7UoZNj+CrSODg5EKSMT1+7QQ5zA4kb9TfcKDFZQi89CXLZlUqRMvzaCkhN6y
	wJicO856qFkqs8qcKcYJrO5av3TmWNCGTDKksvKLqdtbjHHPZEPUfHGU0cB0Hfwe7WFquVbvvJW
	GSWTy/FhRXhUoeQm3tBSFqJXrzkdVXn4u3Lw3dZDSQDQSGbt8ChS6aDUz1WIP3rR8uB26Iz6Y5s
	A7EBFSiKZpP6tk6OYey6NuSz0buiVu8C7FRhYGyp4LWzExjYpF19i0DrFX0bX9TZ5YVzsMQPBfF
	P
X-Received: by 2002:a67:d804:: with SMTP id e4mr5269863vsj.7.1548441896893;
        Fri, 25 Jan 2019 10:44:56 -0800 (PST)
X-Received: by 2002:a67:d804:: with SMTP id e4mr5269845vsj.7.1548441896348;
        Fri, 25 Jan 2019 10:44:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548441896; cv=none;
        d=google.com; s=arc-20160816;
        b=vlS16bEXi0Z6UqvRjq3iZbUZvk7muUIyI3mt5P3gNEpWC64Qf24G7q7QAxzIQeb4ul
         Y5winWlxhHr+X0xaBxpUdpSWjOtwXfVFqiA5JbmdglV6o7D0KFl/Zm9Y46vh3lXsAEMO
         +6j9Yd4AO1b8edaIkQ9ahekv7dkurQzMJbVT0SHXzILowgIAg1hGzUm1a46NDGztqjuv
         tyPMbQvkCry7ynGmOwVC7tUc3vCor7k8IzjLC6hY1b+udJKJycAj4X3SOd1kEnzVi8XA
         vnePK5ooNqJ38r6FC726MNwF7DPO5GkioJfHAeIdjL+2E1D2QA0zQ84B4OftDx3VHk36
         7Tsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mgiQ1AS1vbH52Fdhlzx0yBS0Qcj/v4CjMVy9B7SV8gQ=;
        b=k4Kfqg+NWYoq37CIyP4y/92PZr7SNQ/neOrPVAIJwmwYlhJaoElFeM2IeuXG3WTxES
         iKjzGHTlwn375LEDbzVuEaVXeJEv7tFhOjRobE/9dTllPF3W/dI+2Eb8WOeRNrZKkCKO
         r7GQvDSuiX9RtS7OCI+WhJlCaE6HFWmHQrAc1ShiBKTzsfFxUknN5O75V4skqxlDTepa
         xLfHlCGt8HSdKSdTfWIi2oxwBvei7SK0MGE26kfK4bg7eq7Cs5+UrzFJam2/7yWMSGPI
         +CrxIuAkIXw4CckUcLu073hhPTVdWUsa/vmTuysDgAJgkWRZx6E0UJvsVFSmX0oeJDTE
         AXSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=OWTKgxsR;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g21sor14447910vsi.3.2019.01.25.10.44.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 10:44:56 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=OWTKgxsR;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mgiQ1AS1vbH52Fdhlzx0yBS0Qcj/v4CjMVy9B7SV8gQ=;
        b=OWTKgxsRROMExtBfkf0bxxcq0zQINpUefyMVFPVXOD7Ow1GJhPS1F3XVpEUazOyoPC
         B1fPtJERXRLxCQX5VG1AlmKhbDkZtlL80flYdMYT2hZpyHyHT7FezvASf1PdBvcpGS0k
         V8rIWejSfPUpU8eHglkabuMuE/Imstz6FB3QI=
X-Google-Smtp-Source: ALg8bN4Oad7YAqxkKNNdBJ3LMsuVUN4o217HYIjvbSlAh/RGZeya5Bl3qi0rKbo8rP8XtzGCA4sWPQ==
X-Received: by 2002:a67:46c8:: with SMTP id a69mr5138026vsg.45.1548441895754;
        Fri, 25 Jan 2019 10:44:55 -0800 (PST)
Received: from mail-ua1-f50.google.com (mail-ua1-f50.google.com. [209.85.222.50])
        by smtp.gmail.com with ESMTPSA id a6sm14950866vse.30.2019.01.25.10.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 10:44:53 -0800 (PST)
Received: by mail-ua1-f50.google.com with SMTP id d21so3574735uap.9
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 10:44:52 -0800 (PST)
X-Received: by 2002:ab0:645:: with SMTP id f63mr4915124uaf.106.1548441892334;
 Fri, 25 Jan 2019 10:44:52 -0800 (PST)
MIME-Version: 1.0
References: <20190125173827.2658-1-willy@infradead.org>
In-Reply-To: <20190125173827.2658-1-willy@infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Sat, 26 Jan 2019 07:44:40 +1300
X-Gmail-Original-Message-ID: <CAGXu5jJ=yHXC_S_o6V4QQ+DCV4w2T-tw_BiUXDAW2a8rZDhZJg@mail.gmail.com>
Message-ID:
 <CAGXu5jJ=yHXC_S_o6V4QQ+DCV4w2T-tw_BiUXDAW2a8rZDhZJg@mail.gmail.com>
Subject: Re: [PATCH] mm: Prevent mapping slab pages to userspace
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Michael Ellerman <mpe@ellerman.id.au>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190125184440.UPx7HuAAa_V4gogEIgMhqzSnPWJjIgkvVrIkr9YHINs@z>

On Sat, Jan 26, 2019 at 6:38 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> It's never appropriate to map a page allocated by SLAB into userspace.
> A buggy device driver might try this, or an attacker might be able to
> find a way to make it happen.
>
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9dd823f..ce8c90b752be 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1451,7 +1451,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
>         spinlock_t *ptl;
>
>         retval = -EINVAL;
> -       if (PageAnon(page))
> +       if (PageAnon(page) || PageSlab(page))

Are there other types that should not get mapped? (Or better yet, is
there a whitelist of those that are okay to be mapped?)

Either way, this sounds good. :)

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

>                 goto out;
>         retval = -ENOMEM;
>         flush_dcache_page(page);
> --
> 2.20.1
>


-- 
Kees Cook

