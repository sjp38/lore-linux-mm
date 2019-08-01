Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5340C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 17:30:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EE9220838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 17:30:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EE9220838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=chris-wilson.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18D488E0003; Thu,  1 Aug 2019 13:30:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13D8B8E0001; Thu,  1 Aug 2019 13:30:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 005A08E0003; Thu,  1 Aug 2019 13:30:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A74EB8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 13:30:55 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t9so35964593wrx.9
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 10:30:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:in-reply-to:cc:references
         :message-id:user-agent:subject:date;
        bh=XWBOBv1CfMsXblw8z4vu5On05SfBCxvjabVtvc0TdI4=;
        b=XbQ4S8L9Z8lWyeVaesMLS+zBGzv+a5YwdLNLAaIVduuOImLPeCMBeIvTFD+ynqz04M
         6Ez+13yUN8On02QCiZdcjT9vdsIufUQRqP7Y7SmIGLod9nySYcAIpkVFdJECL4+32TGh
         akUHXWaHvZKfPVFhsQOUYjtppu3FTH3hJJehvYjYDlbJsULPMwyw2/P061YbX8lkvRse
         n6IwSPy3UFSvL03SvveQrbhqhJ9+KET0cMJgU2b+eyH3oIVrDxneHljPbvXqSVlVGDAo
         fq6lcyoRWLIkTJdEa41dDc+PZdhp3QvKQ+fchCaaSJ/DxHfCy1vyUa2xX0t/PHccrzVz
         97KQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Gm-Message-State: APjAAAUiJMKcSOJQjZpnlxnWSdZg2ASpkbDYIinLuSu0NvF4THpcISE9
	hlfICP5rI2B59HjSqiqDryMo4n7XsddvWkSFz+M6Kh2Yoj5fbxy7JLV8XSHuG9mLbiWtm1lv1PT
	i7rrxwC2VDEzZGCP4+dKq40UpJytfWTwEOXIvDhfAj4+wuR2NFtFevZsWlkSu0Kk=
X-Received: by 2002:a1c:a997:: with SMTP id s145mr114434863wme.106.1564680655209;
        Thu, 01 Aug 2019 10:30:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqrMiYrTTs2IF1fX/+n7cmUszH6EjgkRDnGFELMxBpRnC50dmG3NClfDKHf8a7K00Atvmv
X-Received: by 2002:a1c:a997:: with SMTP id s145mr114434818wme.106.1564680654367;
        Thu, 01 Aug 2019 10:30:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564680654; cv=none;
        d=google.com; s=arc-20160816;
        b=uICgMVc96gtuEFK+n7ALWXjKuSXUSfSuUfvdPAbj75UPtJnnHlIZAsbwHyHtoUhsOB
         292XZDKFDSffP7AGHqsMCAYtozgi/NWyHIloKVCTQdH+M4ibeppzRYiBNuXmaXdbWvp1
         7hDIxE0rsqXEv4l7BMwleCa+mAPOJFx9o0b3gfAi68m2e/5LuWvA+IGRFJ8Eb81wGawh
         t/xWyh2yLkbEKiIvP87XotRPB6nXg8BIBBecjXZ7xU7R1PGrZ3lNMMD0v87ZCpDhWV4b
         E5UUSS8Exp3w+ROcsjH5OIiE6WPmQDz6YlO7F6XNgwVMRFaEDP/xVp22uJI0TMyL+q0V
         Bd4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to:from
         :to:content-transfer-encoding:mime-version;
        bh=XWBOBv1CfMsXblw8z4vu5On05SfBCxvjabVtvc0TdI4=;
        b=cbznG3ciqTf/jnhwOYU7ONlf7K9E4yKpqs+EKiea41OCsuHd38Dj1QBlugIiARLgjT
         AnvSUscMzEGLY5fv/I1OkS4ftccfVUJciToz/+739jzDG3pvVwzhwJxso79dO5CsDEGk
         d6KidOS8r4fay1H0ezxpoC0rKl2mkOWqatogx+SWdw30qbp0iZsPFfwmyn3LddcBjEoE
         A1YMwrRyxHHrxJT5cWwJahcQG3GtYLwaO7wAPeq2k11O6bIgIhJhRVyRlcgl9nhIBYAR
         7tN2LpGszi925UrvvvMRNp1lYR+r0PAQMhX4c/ifckbj1cIKS39jFhbQY4jzYEYeJx3b
         EujQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id u23si76832697wru.84.2019.08.01.10.30.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 10:30:54 -0700 (PDT)
Received-SPF: neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) client-ip=109.228.58.192;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Default-Received-SPF: pass (skip=forwardok (res=PASS)) x-ip-name=78.156.65.138;
Received: from localhost (unverified [78.156.65.138]) 
	by fireflyinternet.com (Firefly Internet (M1)) with ESMTP (TLS) id 17794926-1500050 
	for multiple; Thu, 01 Aug 2019 18:30:47 +0100
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20190731164829.GA399@tigerII.localdomain>
Cc: David Airlie <airlied@linux.ie>, intel-gfx@lists.freedesktop.org,
 Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org,
 David Howells <dhowells@redhat.com>, linux-mm@kvack.org,
 dri-devel@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>
References: <20190721142930.GA480@tigerII.localdomain>
 <20190731164829.GA399@tigerII.localdomain>
Message-ID: <156468064507.12570.1311173864105235053@skylake-alporthouse-com>
User-Agent: alot/0.6
Subject: Re: [Intel-gfx] [linux-next] mm/i915: i915_gemfs_init() NULL dereference
Date: Thu, 01 Aug 2019 18:30:45 +0100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Sergey Senozhatsky (2019-07-31 17:48:29)
> @@ -36,19 +38,35 @@ int i915_gemfs_init(struct drm_i915_private *i915)
>                 struct super_block *sb =3D gemfs->mnt_sb;
>                 /* FIXME: Disabled until we get W/A for read BW issue. */
>                 char options[] =3D "huge=3Dnever";
> -               int flags =3D 0;
>                 int err;
>  =

> -               err =3D sb->s_op->remount_fs(sb, &flags, options);
> -               if (err) {
> -                       kern_unmount(gemfs);
> -                       return err;
> -               }
> +               fc =3D fs_context_for_reconfigure(sb->s_root, 0, 0);
> +               if (IS_ERR(fc))
> +                       goto err;
> +
> +               if (!fc->ops->parse_monolithic)
> +                       goto err;
> +
> +               err =3D fc->ops->parse_monolithic(fc, options);
> +               if (err)
> +                       goto err;
> +
> +               if (!fc->ops->reconfigure)

It would be odd for fs_context_for_reconfigure() to allow creation of a
context if that context couldn't perform a reconfigre, nevertheless that
seems to be the case.

> +                       goto err;
> +
> +               err =3D fc->ops->reconfigure(fc);
> +               if (err)
> +                       goto err;

Only thing that stands out is that we should put_fs_context() here as
well. I guess it's better than poking at the SB_INFO directly ourselves.

I think though we shouldn't bail if we can't change the thp setting, and
just accept whatever with a warning.

Looks like the API is already available in dinq, so we can apply this
ahead of the next merge window.
-Chris

