Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3A27C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:02:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69B7A2080A
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:02:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DYedy/H2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69B7A2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA9836B0008; Wed, 12 Jun 2019 14:02:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0AF36B000A; Wed, 12 Jun 2019 14:02:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A84C16B000D; Wed, 12 Jun 2019 14:02:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F52A6B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:02:33 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id q12so2740954ljc.4
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:02:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=TGyEZqVem3TEHwS4z5kwkz/UD1vaH7FY4ZFlgRPNsPc=;
        b=BIoF6Kyex3hzik5pn4Jxxr+G3dGEfKerAFz6R/+qEUaIUYdarLsJFqhsTDetOPG9jN
         LGWTn9x1ixUQuw4n2U79It6EqOtP+VG8OOKDmg/v9jNQx8bPkcPk1x6k2veeXIw0Zve6
         91fvvRIn8JoKs8LsVApr+0px4c7m74YUbUWaVpIv0la/gJR0vadK3DhvqNtNo0vRlcCR
         enpMdeoPg/jPfzE65FdJ/75HAd/j5VZr0hx5tVwgAD5OJDU+kWXmqhnlHAVEORout7YS
         XgC4j7wpsT1U4mIhhT3cHONebhJdd7mKaqn5At/pQNwTfPwd7ERG3E7QCrPsvIswrwcV
         j4Ig==
X-Gm-Message-State: APjAAAVTASaNHdt5fhko6DXwU/xbyPqjCa5HZyKlO9jiWZreacgP5PvN
	hydtBHOFZO9hwWtC/s+uvlV6MQckAb1puhDwvNt+9mwzrINiidZz0xsBRlXYL5uDFB1RdUGO6aL
	dUCpy8lCtIMuIi6Tq/wequ0ZsdImiITfMfPThe0WYGRk82vJAcIAh8v0fMXr9WnD7JA==
X-Received: by 2002:a2e:82c5:: with SMTP id n5mr5044429ljh.175.1560362552357;
        Wed, 12 Jun 2019 11:02:32 -0700 (PDT)
X-Received: by 2002:a2e:82c5:: with SMTP id n5mr5044402ljh.175.1560362551517;
        Wed, 12 Jun 2019 11:02:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560362551; cv=none;
        d=google.com; s=arc-20160816;
        b=gz/0A+uveJ4ZzKkLt5dtJzCw18xZlGSDSzmmE2Ragau/EDOfIsrz1wUTr2rEJ3X6uP
         NcfS5nKvSGMIxnprsLDLS1lJ6blo5nXALeUQ+ZhQLCG7idqmkhf/qz1XcQD5DQVB7Y6B
         BiTCFIgN57Gtz0TqGU2QJKRW+kFeyhLTTKTqQjkCV4rUtGGFvMjedeYkpxN+b6J+x+XH
         QS8ixQGOnh6c0poSLr33l5UG18ttswRkHWDhwFYGmqh3P8Sae3ZWx8Jbq7mLX/I2TPXF
         GYzStCrwzgkVq0eqoMrbaESr6n9F4ix3SY781OVo0jLInyB1Ze/naoaJEJt10IIUEtMx
         tZDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=TGyEZqVem3TEHwS4z5kwkz/UD1vaH7FY4ZFlgRPNsPc=;
        b=l812+cwOY9LINljFlnxF7OBxyoOepkX3OIylEtficyPOPrhgVjSY525sI/Wa929BsM
         V9kQbmbe6qWiTU2Z2tQqiGobOZEtP1Xe5iJds+hZT5jZiCgPo+FuUbo0KdXshIUDDY6O
         2bSi1TmeMUJ3MMdYIXS+TN9oqWVET5jv56YodkTUjxrHjqulAZ+C9uOhSTb/JPzB5EzO
         uq0lzcScKbtZPWlsGxOYM/kgL+Y+CFJsy7oVSB5bizZA2rDXaEoEJr/M6B0eXslGv0e5
         3KLUac4mvb9/aZfh52ZyxJ2ff/etxd23XNYUTnsisG0Je/cCYc/TzcfP6iGqNArhgYFk
         OBdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="DYedy/H2";
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t26sor327852ljj.2.2019.06.12.11.02.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 11:02:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="DYedy/H2";
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=TGyEZqVem3TEHwS4z5kwkz/UD1vaH7FY4ZFlgRPNsPc=;
        b=DYedy/H2MeX/ziKv4RNgxEi0S6NxTFXFYkyu741FLGtX7iVxx+6oZzIcnNBFu2Ye71
         cDVvYW0kcbrN0dvMf8LJED0Dkk0JwvuWJwYj450fJgO8+Q/OgbKwwtIj3i529pXZclB2
         UyC14KmtGU7sTvSoi8nArLvN3IV7VlGwrzRDHm2BUvFBg9Y3gP8xm7lAc9Zvv/5zR5Rd
         GXYGoI+aK1hdsXSs4iEr0dm3gc+6W0xmMz+D7e8DW5lhXAzvLPiGt0sXN8O9glJg4BNs
         PemyILlzELQSOLcT3muorEFb5AOxn5EK2SkerwECrH1sHxiUfLdMzKerggyqBGZRAIan
         aTJg==
X-Google-Smtp-Source: APXvYqxlUkVBSYAPr4HvZbkTUk9XwAEtvl/HstLRHv/G7/ed4CIK4pz5Oot+oHDdl/jEJ4yghTPD3Q==
X-Received: by 2002:a2e:5b94:: with SMTP id m20mr35412878lje.7.1560362550740;
        Wed, 12 Jun 2019 11:02:30 -0700 (PDT)
Received: from uranus.localdomain ([5.18.102.224])
        by smtp.gmail.com with ESMTPSA id u18sm91160ljj.32.2019.06.12.11.02.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 11:02:29 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id 69C864605BC; Wed, 12 Jun 2019 21:02:29 +0300 (MSK)
Date: Wed, 12 Jun 2019 21:02:29 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Laurent Dufour <ldufour@linux.ibm.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [RFC PATCH] binfmt_elf: Protect mm_struct access with mmap_sem
Message-ID: <20190612180229.GD23535@uranus.lan>
References: <20190612142811.24894-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190612142811.24894-1-mkoutny@suse.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 04:28:11PM +0200, Michal Koutný wrote:
> find_extend_vma assumes the caller holds mmap_sem as a reader (explained
> in expand_downwards()). The path when we are extending the stack VMA to
> accomodate argv[] pointers happens without the lock.
> 
> I was not able to cause an mm_struct corruption but
> BUG_ON(!rwsem_is_locked(&mm->mmap_sem)) in find_extend_vma could be
> triggered as
> 
>     # <bigfile xargs echo
>     xargs: echo: terminated by signal 11
> 
> (bigfile needs to have more than RLIMIT_STACK / sizeof(char *) rows)
> 
> Other accesses to mm_struct in exec path are protected by mmap_sem, so
> conservatively, protect also this one. Besides that, explain why we omit
> mm_struct.arg_lock in the exec(2) path.
> 
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> Signed-off-by: Michal Koutný <mkoutny@suse.com>
> ---
> 
> When I was attempting to reduce usage of mmap_sem I came across this
> unprotected access and increased number of its holders :-/
> 
> I'm not sure whether there is a real concurrent writer at this early
> stages (I considered khugepaged especially as setup_arg_pages invokes
> khugepaged_enter_vma_merge but we're lucky because khugepaged skips it
> because of VM_STACK_INCOMPLETE_SETUP).
> 
> A nicer approach would perhaps be to do all this exec setup when the
> mm_struct is still not exposed via current->mm (and hence no need to
> synchronize via mmap_sem). But I didn't look enough into binfmt specific
> whether it is even doable and worth it.
> 
> So I'm sending this for a discussion.
> 
>  fs/binfmt_elf.c | 10 +++++++++-
>  fs/exec.c       |  3 ++-
>  2 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 8264b468f283..48e169760a9c 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -299,7 +299,11 @@ create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
>  	 * Grow the stack manually; some architectures have a limit on how
>  	 * far ahead a user-space access may be in order to grow the stack.
>  	 */
> +	if (down_read_killable(&current->mm->mmap_sem))
> +		return -EINTR;
>  	vma = find_extend_vma(current->mm, bprm->p);
> +	up_read(&current->mm->mmap_sem);
> +

Good catch, Michal! Actually the loader code is heavy on its own so
I think having readlock taken here should not cause any perf problems
but worth having for consistency.

Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>

