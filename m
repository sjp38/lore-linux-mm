Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A67BC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:59:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6A6020656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:59:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="TR/Xs+H4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6A6020656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78F496B0005; Tue,  7 May 2019 12:59:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 719AC6B000A; Tue,  7 May 2019 12:59:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5939B6B000C; Tue,  7 May 2019 12:59:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5B0D6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 12:59:07 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id u14so2967988ljk.11
        for <linux-mm@kvack.org>; Tue, 07 May 2019 09:59:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JvOdwodHOTVYJ7+EHobDSJoXyA/2IRefA+hgBIaO+dI=;
        b=UTg+m+2bkGYm8g+d9v5GRHUvQVOhDk4CzyyYx3w2gc/n93kC4mw9trAQqzJSrc0sfB
         NzwEnEwDTB5eguPm29pmAlRwq8yvvjLue0BkLilLGseve3z8rhgdmXMkaLPmQZLhodn4
         xE4ag1gUh9MJTVXcDzRZe+wEoJSjedsj1vwg9pXLg90KPhjyEx33v77AJb/ZzAUmd4A/
         rYdLa33DbpZ8Iy+0MHRyLcBJh/xioP2StJHk61c/9DLG4UuA8ZPs8kWGhz0FVHK+q43a
         sZrw3cv2u9iUG2w7EZEydokvqXuD8DkMox+i7169YOLGaoAXYv8u56AQsgP7CaiD8AIM
         rV0Q==
X-Gm-Message-State: APjAAAWJwjJZWy1St17TJphHwbZJkHdQ5mCAIW9SbxrTpQXXm+aKJEvP
	Wh93G63BgX+oFE0Cn+6X34c6vkoidaWB4LXpO0p17LHWlZ4uCFZ2Nm22+IJ0HbXv+swD53GSgfI
	WWsBnMVkZ6o3ON+txw/6EdCMuTAZ8zRgYc3EJLoN9kt0YOrMF0DW5outpLkijtZ9zeg==
X-Received: by 2002:a2e:9252:: with SMTP id v18mr8895400ljg.119.1557248347087;
        Tue, 07 May 2019 09:59:07 -0700 (PDT)
X-Received: by 2002:a2e:9252:: with SMTP id v18mr8895368ljg.119.1557248346413;
        Tue, 07 May 2019 09:59:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557248346; cv=none;
        d=google.com; s=arc-20160816;
        b=XsUz/7K9LFpzCYpgfx2GcExg5YKilODIIlulXNTxSRgMN7LumJb7i38hWcbmqELhhl
         hiMB5bAHoF9BlspmM0gW0kmQA3eilZGy6fcQ7JUvTgWJ2iE8X3d7+ndHwn8BvQLX0Z4L
         WALcO8HPQWDTon7na31OfX+xXk0bYU+o/o5sRPeKQKsUjdBxqSHtQ4KBriplICOPzj0R
         r2afXaqplNchMD39D9tN9b1gmdiLSLdx0AtJvHbm69ns5MdALSK+58To7qN3JDSpPGVK
         Gh3aLPwIm4+mT6koJyYwdAzLIrw1zOPLWQdbmkBC36I/8rZlVJLJ8jzf+QPKHFL+oQ2i
         MvZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JvOdwodHOTVYJ7+EHobDSJoXyA/2IRefA+hgBIaO+dI=;
        b=TU+k7a5Dkocym8ArhMSYl13QSKq8JpOhKaYxDNN95Fx7VEX1m6tel9ZPNNxaugAxz0
         1DwdWfEPrsbWU6wwuuTk48IhwERESHqFugbTzONfdBS9DA2EqKq/Pdq9t4peDZ//3zis
         4seI0yJMmtaeW3ivUOJtnIO7D9KiYokXyThGwQIjWNHfKIu4urGgA5jflBfPB+3OYaX5
         vwwvI/WEbMBGEsZL0FasXfQFj/Tnb50qXL8MBVuyEZMZi1DIcyprbudLUd6UOpoCiuM+
         9zUOronL2BGsN77dWD5zcbwSe41XtBCCor2r/QgguYgHqJMIhYJhZEhC+iTmTrOVeFtx
         uu2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="TR/Xs+H4";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t6sor7584271ljj.15.2019.05.07.09.59.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 09:59:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="TR/Xs+H4";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JvOdwodHOTVYJ7+EHobDSJoXyA/2IRefA+hgBIaO+dI=;
        b=TR/Xs+H41+MJkfZoDS3QvaRnKQ/g/aV8B8CcLFu7NSmvalIZMpHgldvoVhvFAQWvJv
         6nl9q4q1e1O09qZYjSX8DYPCKpQIHf0ugzOG6HjVOxJ3jM8B5tGB1rixMuYMwT8a5WVn
         OXpYD75kQFmL1W4AwtTiKcN+UF6bsE/Un6etg=
X-Google-Smtp-Source: APXvYqwoDnpercsvpo8N+z2TWjEv2xnD16Frw62znMYs5XfsMewP7Ga7AQu6eCSLgbOQ0T5SwTphXQ==
X-Received: by 2002:a2e:c41:: with SMTP id o1mr14175061ljd.23.1557248345578;
        Tue, 07 May 2019 09:59:05 -0700 (PDT)
Received: from mail-lj1-f178.google.com (mail-lj1-f178.google.com. [209.85.208.178])
        by smtp.gmail.com with ESMTPSA id r9sm158474ljb.79.2019.05.07.09.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 09:59:05 -0700 (PDT)
Received: by mail-lj1-f178.google.com with SMTP id d15so14984523ljc.7
        for <linux-mm@kvack.org>; Tue, 07 May 2019 09:59:05 -0700 (PDT)
X-Received: by 2002:a2e:801a:: with SMTP id j26mr8701955ljg.2.1557247866889;
 Tue, 07 May 2019 09:51:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190507053826.31622-1-sashal@kernel.org> <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
In-Reply-To: <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 7 May 2019 09:50:50 -0700
X-Gmail-Original-Message-ID: <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
Message-ID: <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Sasha Levin <sashal@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	stable <stable@vger.kernel.org>, Mikhail Zaslonko <zaslonko@linux.ibm.com>, 
	Gerald Schaefer <gerald.schaefer@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, 
	Michal Hocko <mhocko@suse.com>, Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, 
	Dave Hansen <dave.hansen@intel.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Sasha Levin <alexander.levin@microsoft.com>, linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 9:31 AM Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> Wasn't this patch reverted in Linus's tree for causing a regression on
> some platforms? If so I'm not sure we should pull this in as a
> candidate for stable should we, or am I missing something?

Good catch. It was reverted in commit 4aa9fc2a435a ("Revert "mm,
memory_hotplug: initialize struct pages for the full memory
section"").

We ended up with efad4e475c31 ("mm, memory_hotplug:
is_mem_section_removable do not pass the end of a zone") instead (and
possibly others - this was just from looking for commit messages that
mentioned that reverted commit).

              Linus

