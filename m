Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2341C5B57B
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 23:45:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D679217D7
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 23:45:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="L9zsQCD3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D679217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 259DC6B0006; Sat, 29 Jun 2019 19:45:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 209528E0003; Sat, 29 Jun 2019 19:45:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D0D78E0002; Sat, 29 Jun 2019 19:45:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f207.google.com (mail-pl1-f207.google.com [209.85.214.207])
	by kanga.kvack.org (Postfix) with ESMTP id CBBB26B0006
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 19:45:08 -0400 (EDT)
Received: by mail-pl1-f207.google.com with SMTP id x23so2498351plm.19
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 16:45:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jGY0WqKqadyH+XHv8Sy1BRyYmnp1DIN9zkJBp6x16yE=;
        b=udGwKZ7I/YdSTUKE84oH9dz9mG/nuKovDj/5FlYmyf4SjiR1PQVHhnwZQSiSNXtPHd
         z/MjTMdrDQCI8OhVvNSP3YZpmbLW5dh1wT4L2J4WZqiirq5gSJQo81/vmtBlBPj+OYAV
         9+j5BswJVz5v8yDHz1V07f72FCZ20IhhFMIEw2ANvZWKqtZ5i4YDLv5eUdNOEJUWcQXv
         341eo+DskI83NrFuHO7ek4xQh4P4KeyVXZDBcW9EDr1bhJ/w90fcezDRdDEAykUK7bVK
         slyEcZrpFUF4hEBeozQq+D/+o/xPtV1YauwNcm/CbuEV/qN08u/4iEBxw6Oqkez7Vkua
         Zs8A==
X-Gm-Message-State: APjAAAVMvyRX54rv5MyfBGS0PqpRTTIV1gISc4iM0QBr9xx1q4/azqA7
	JGWmcZqOq9N6tWol74mAHLzyM4cGiwbMZyv0hFtxvCAfpUBC1Avdqs6qnoBxPXw19OPiCwCHkd2
	X5f9KK4tH9kSnCW+gwsSLK8KLXax2s/sy+y9voDt+NdLSdHpkEBZyIgneQ2IU6NXQPw==
X-Received: by 2002:a63:6f8d:: with SMTP id k135mr16760061pgc.118.1561851908398;
        Sat, 29 Jun 2019 16:45:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyP2gsG57EFTxdAflCoTqxRWbnecYUfmQUqPDOYDn3hnLWY2wGPDRIScNjgUFBGlKGFkKJU
X-Received: by 2002:a63:6f8d:: with SMTP id k135mr16760009pgc.118.1561851907596;
        Sat, 29 Jun 2019 16:45:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561851907; cv=none;
        d=google.com; s=arc-20160816;
        b=YBf+1RgbRqpb6qBPSyFq0vlX3uUASBlBK/osjilNX+iM6Zm86serO9Nm1Un85/9lGE
         kt1zmUvecW+JmsznML7ZqtvLkNiOQGdBkaPb+UfVuejDie2DjyOG2MB34owzZ2cy4DAM
         HhmC9UbI8Sml7FqyM5+NwdgMjnjebj3lXy9d82JGiXlk24+u91TqOGb5IRk9811VVoPL
         gTCPe92txAuu49Exq/g4K/X+9NJHhuPmiscifa025mwwrsb7zdkMUDRmn45qCOjjEdTP
         YnS9xp6WubSCrx2Y/X4lnd8r780E75we3sa/M7BxSjS/ylwSkpHeTaOy+FNJIYIFTo0B
         XMHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jGY0WqKqadyH+XHv8Sy1BRyYmnp1DIN9zkJBp6x16yE=;
        b=G408z9mkoiWlIVynyRx6LgnDO4sd4klWs+Z04d7EWvNjJCURL2+vJu6qAg8la5JKrk
         cB27HHCk2zDVxpW+qzLf+PbdRyCpx07isIXddwcywRRt7XyLGzRB9moyBx71EqJx9hsO
         CT3E9EPxseekwg0B+2BdDUzRrM93luNeFnEKrMt5BXKHMUDuA1RkxsYJ6FD6Dmdmppgc
         HnMjB4C9kp+8EnekpmdMzE+k4eKpK+gMQweTfS44jG3Sj94ewFPQmsnwx4KzwsEYCdzZ
         4Vl5f0v4ZI8JfbJKU6Ds4SvlvUuWl92EXG7QKKi5rIMsrluMPNp8FBagWj1YMkr8XHxh
         TlOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=L9zsQCD3;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a14si5875098pgm.206.2019.06.29.16.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jun 2019 16:45:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=L9zsQCD3;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 10A6C217F4
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 23:45:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561851907;
	bh=NO9SldPrvEHCV9L05HomDu1WyC6FUgdLlHc97KSTRsQ=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=L9zsQCD3SME4yCdiZ91gR5mu3dTU7iHytvauDPWLVWJ5PVYhrkz4Xa1e7uv4wAgV3
	 dn6A6uxhscIfZ/fM0Q/M50uV8Zprd9O/fI/u2BZF1R7eLQPpJWxVUZ9macy7ZQ9u1d
	 B6qcP8VfgVBU5+U66FxTgTcWis+nQEC2Uneo6t/g=
Received: by mail-wm1-f47.google.com with SMTP id c6so12285048wml.0
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 16:45:06 -0700 (PDT)
X-Received: by 2002:a1c:9a53:: with SMTP id c80mr11059844wme.173.1561851905663;
 Sat, 29 Jun 2019 16:45:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190628194158.2431-1-yu-cheng.yu@intel.com> <20190628194158.2431-3-yu-cheng.yu@intel.com>
In-Reply-To: <20190628194158.2431-3-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Sat, 29 Jun 2019 16:44:54 -0700
X-Gmail-Original-Message-ID: <CALCETrXsXXJWTSJxUO8YxHUo=QJKmHyJa7iz+jOBjWMRhno4rA@mail.gmail.com>
Message-ID: <CALCETrXsXXJWTSJxUO8YxHUo=QJKmHyJa7iz+jOBjWMRhno4rA@mail.gmail.com>
Subject: Re: [RFC PATCH 3/3] Prevent user from writing to IBT bitmap.
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, 
	Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, 
	Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin <Dave.Martin@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 12:50 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> The IBT bitmap is visiable from user-mode, but not writable.
>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
>
> ---
>  arch/x86/mm/fault.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 59f4f66e4f2e..231196abb62e 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1454,6 +1454,13 @@ void do_user_addr_fault(struct pt_regs *regs,
>          * we can handle it..
>          */
>  good_area:
> +#define USER_MODE_WRITE (FAULT_FLAG_WRITE | FAULT_FLAG_USER)
> +       if (((flags & USER_MODE_WRITE)  == USER_MODE_WRITE) &&
> +           (vma->vm_flags & VM_IBT)) {
> +               bad_area_access_error(regs, hw_error_code, address, vma);
> +               return;
> +       }
> +

Just make the VMA have VM_WRITE and VM_MAYWRITE clear.  No new code
like this should be required.

