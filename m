Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3F60C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 03:11:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 838612182B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 03:11:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H9gmGEgl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 838612182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16FDC8E0003; Wed, 26 Jun 2019 23:11:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11FFA8E0002; Wed, 26 Jun 2019 23:11:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00E728E0003; Wed, 26 Jun 2019 23:11:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id D523E8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 23:11:48 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id m1so979573iop.1
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 20:11:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Q96TkVsJnfnxVeWX/AdudLxYyvC01VLk3tE7qk29U9Q=;
        b=FF2B4fCyHqL1BFis0V2hwXP+ld7WGzEfJuTMfljWt3vXD54r1iMxSSpbMTWxTqPJGE
         ER3SeCq2FLcl5vy/FJ9h5XFuP+02qQPxjUlRq3Rw8SFtFIERwnvz4yQBHVq8kc4q4/Sp
         4UnLdnegkXOidwXsPFUCQY8QiYJZmQdwSTzeXNKdfhQtFXxIa5kXIkZdC+4a2azz0nY8
         GDnktu0gIqyJVBt5o7mjhq7pKRoCGIfYLfwQTRA6nq13rmAjW67U5NQJSu+YAuMcsiZ9
         b8+zBgcru3u7C46AG+0y/dXAt14UMa+NjNKq6jtD1wbMcmUD57wKS11pD3dd3tbKI2gO
         PxkQ==
X-Gm-Message-State: APjAAAWaHK4fl8WJG2tWLkNv4d2j3/0m0Q0vLgoEvMLEs6QJLiQEnSX6
	ezSTk7S58soYHc3JxTP+F6vrdGgnieutG/hGzyZPLkV36m4bDxinw4f0JjiZjgYssI5NCNTqofX
	WaU6bMoWMo8L3lQFG4xke4A25+iYQjnSP25Ha/PnnlV9sVRUDkNGvYqv09Nv+VqECIg==
X-Received: by 2002:a5d:964d:: with SMTP id d13mr1975703ios.224.1561605108608;
        Wed, 26 Jun 2019 20:11:48 -0700 (PDT)
X-Received: by 2002:a5d:964d:: with SMTP id d13mr1975665ios.224.1561605108011;
        Wed, 26 Jun 2019 20:11:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561605108; cv=none;
        d=google.com; s=arc-20160816;
        b=hOzFcBBsZq2+YLrNKIc6mcYnWkdi32ohfjy3UfpYOf2a2yJCe+yuYiImlPVSUe8i/B
         rS2sj8Qsz3bd2fXuZqDKPfc/Iuq+ZlvT6EdgX3HxZomb2HJnrj9i8k9ABSMQldk3qoPB
         1TwzkboMws2YQn0SjmJraJrMjFsevsZUBLb9tz4whNJ54g1wB6/jDwMbKVRcunkaprOJ
         SmGxjiadugnP6OHzjzz+doUkY3GIowxf00FTrGU54u0FkJ7S9oCj8NNEstilE0z1PBV2
         kKBzSlpx9Tkdn2G2jaUxfY/CJBYMhp4R6jPaydFAHKxY9snXSBxNlZiz3LlmFWjjjCRf
         gBaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Q96TkVsJnfnxVeWX/AdudLxYyvC01VLk3tE7qk29U9Q=;
        b=bK/SAZnkGo6ddmLjxSg++HF9pSoHhg2l+rjTvbgN8aKtttyF8sDyiFPONk/NchnVtX
         FblCrVjHyz7A8H03W1grngklOGlSiiGDukwgGMXjSBJZrAfki1R7AmqQO8JMSrhNvZ2U
         s76/IRiss9VJW5hQcuA5oyHgXOK0G+O6FhVdL0OOzKxOCmOyFLSzFL9KIJf8H9yNTFOb
         8JLSgWQ3NI99IeYza1rey5hKUGQ7tUD+5RvuKdyDQI4HIwgV92MFVLnH6Vq42ZtkemlZ
         XOjUFMrxLRoXNGA69GjRP4HNOWLJt9sW+EB7WC4AtpHi4pWheP/UrR7J9rqor9519atT
         zGlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H9gmGEgl;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n31sor1978859jac.0.2019.06.26.20.11.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 20:11:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H9gmGEgl;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Q96TkVsJnfnxVeWX/AdudLxYyvC01VLk3tE7qk29U9Q=;
        b=H9gmGEglIn+LAw9pG4lAyeC7GhEDYFCJpfJVAp3JJqXANo/tVpzC+GJcFcrlYpvbj6
         LZm186SGKl9CFSNXORhYuyjBdwTM7KPKNscLWSd/EYAmijYajHPGFqMTpy6Xc+zbvw4w
         WT0h/+6gaQSq8OTkWhmAo0q/9hftwqjfoS6CsX9FhxyKJ3Q2XoH+taa414Ic5ZbhK78f
         tWqXR+NYSVL0F6zfy5hSTKhH36gP6+7ucDnu/+JHvNsS7N/AOiKsC/zSHcLai4NHKWwo
         FtO3VNKdyMpuxkCe5bQ22L7C4c+1kD34uaGMmJTJ/wb7S7XIjPi3FJOJ4YCXzjgh7f+k
         GaVg==
X-Google-Smtp-Source: APXvYqwtgBUKznYI9WKiA96o5xUtUGO2BS1tjRoGjRXP0Akltu+m1KJzetXfkm3GRRcNfMOyaUKPCNxgs3JB/FHiGWo=
X-Received: by 2002:a02:a384:: with SMTP id y4mr1716711jak.77.1561605107707;
 Wed, 26 Jun 2019 20:11:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190512054829.11899-1-cai@lca.pw> <20190513124112.GH24036@dhcp22.suse.cz>
 <1561123078.5154.41.camel@lca.pw> <20190621135507.GE3429@dhcp22.suse.cz>
 <CAFgQCTvSJjzFGGyt_VOvyB46yy6452wach7UmmuY5ZJZ3YZzcg@mail.gmail.com> <20190626135744.GX17798@dhcp22.suse.cz>
In-Reply-To: <20190626135744.GX17798@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 27 Jun 2019 11:11:36 +0800
Message-ID: <CAFgQCTvAaWvnZYYeg-TqCMtYdgGu-r29iGu4igoQ-RRkRkYmVw@mail.gmail.com>
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA boot
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, 
	Barret Rhoden <brho@google.com>, Dave Hansen <dave.hansen@intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Peter Zijlstra <peterz@infradead.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@elte.hu>, Oscar Salvador <osalvador@suse.de>, 
	Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 9:57 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 24-06-19 16:42:20, Pingfan Liu wrote:
> > Hi Michal,
> >
> > What about dropping the change of the online definition of your patch,
> > just do the following?
>
> I am sorry but I am unlikely to find some more time to look into this. I
> am willing to help reviewing but I will not find enough time to focus on
> this to fix up the patch. Are you willing to work on this and finish the
> patch? It is a very tricky area with side effects really hard to see in
> advance but going with a robust fix is definitely worth the effort.
Yeah, the bug is a little trivial but hard to fix bug, and take a lot
of time. It is hard to meet your original design target, based on
current situation. I will have a try limited to this bug.

Thanks,
  Pingfan
>
> Thanks!
> --
> Michal Hocko
> SUSE Labs

