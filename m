Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D04F1C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:25:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8954D2083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:25:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="G0CVtpqe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8954D2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 202D66B02D4; Thu,  6 Jun 2019 16:25:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B1706B02E0; Thu,  6 Jun 2019 16:25:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C7A26B02E1; Thu,  6 Jun 2019 16:25:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7E666B02D4
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:25:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id z1so1117857pfb.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:25:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DKhd22QxqBDA4KYT2cEZlqhYj/PumKxUwK/zMkdDIFM=;
        b=f49fiQsO7LBC5F48SMZjsknHfxiXENf8uVj5FnUhSiKFW7Nnb7tTyPduTEq2KDG0nz
         jIS2qInYsHIZ805FKCOrRWSXeMpK5vic2W4noT54LalbMiRiSNU+l5zuNTEc9lpmH6Gt
         AhKKMc84IMLio/9oL2yJZu4Mz/nahxBYrrNjoQbBu41pTGwj1qA41zfMWYPH/1Gf0xsI
         RcWxfEWB+NmIRMevZhbQokpUBURFwMLn3Xz7/c/dfjeGAHQSYL/VS9CfSscbDDCUZZ7n
         QpwKnfwQGYn9VtDZklRS7zTdR0R/w5oLARmygUkv+vgdHX28QUo5zCqa//2cmTLWyfiA
         +QBg==
X-Gm-Message-State: APjAAAXltYPg60iAo4ofytoAP3GQjLURP5ZtG6ylK/MvSP6pQUzwVxpZ
	ZbAvrGU9foqVuBX+lX6QrZW01i+Jv3mIZB0axDB0J7UInUQyiS9RAzmAbxkdOhD4zTUMJI9wXyv
	x+pz/JFm8i0PYfh78x4PX5ge6jhHhW9djE073mOke+SSPq6aLQsjeecXDMzHxizhPSQ==
X-Received: by 2002:a17:902:3103:: with SMTP id w3mr51335026plb.329.1559852737452;
        Thu, 06 Jun 2019 13:25:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfuiBMvoSFHAnDluQX8rK05T9U7uH45LWc26GkRvvOC7KcR8iMtOytm7c3h49Ai0XtE6bj
X-Received: by 2002:a17:902:3103:: with SMTP id w3mr51334997plb.329.1559852736870;
        Thu, 06 Jun 2019 13:25:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852736; cv=none;
        d=google.com; s=arc-20160816;
        b=UR2kKLQWAZMxLLrBZOLICsBfKifrGg0B4jYKfRWRtj1KBooRr7Jc7RQfiYTKzB06Gi
         XQIpCF61b3AWZt/lCZ4TzM1WFqfs8uSIflVJJp0NhL/aqDkbrI8CbjZ+znzYm/nSE5jQ
         8uo0Z/uUAe+Mioj0qGQ6GbG2u5g/hvZdsFN6x114osSenpHTqt1MBwloNSu5ffAStAJ6
         qj8A294zQc2fvsuXwuE+CoOpYEIzhXXO+0e6Tfqyh7is/MbvTlBAGQNqAaTcMrgvunLx
         zBNjhGtooFrphzcJzc3NUOxuB4AR4EvoGChXHuVnLZnhKwShdixgqLvxfEeGUNVdocMZ
         JP1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DKhd22QxqBDA4KYT2cEZlqhYj/PumKxUwK/zMkdDIFM=;
        b=q+C00taP9holR1aHBHNX4nu7l1csYtHS5xOusDMVMDUJ2MhiIXVlvCO+wejU7PXKLt
         njygt3zy1QW0dcBRLzCc8ApdeAFJa6xR52KOExyvy2Zzkhlrt/Wr2GUXM04lmd2IxO3b
         kIA+y69sZgHjicH22H4/0WdsEb8DYLCX0BFOPC82aP0tWuqO1DvEoqwIIL+gtMAwLc3i
         tPgC2vpYagoQbwIUyvad8ZYxepysg+dVDNdziWNrg3ms5MWdjMxbVLSIizmQGCrBS1dW
         ZzTpwIeT8WPzWIdEM4BFZ3PaleGnPy3g1hShxqy0msyBtA747fYtTXVxViDx+3hFNSkx
         RG6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=G0CVtpqe;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b23si64960pgb.299.2019.06.06.13.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:25:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=G0CVtpqe;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2B422212F5
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 20:25:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559852736;
	bh=DKhd22QxqBDA4KYT2cEZlqhYj/PumKxUwK/zMkdDIFM=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=G0CVtpqeJtYYi6ZVaBFtvvXvsAJWteRf+Hozt3FdnG/AgCfB13Ad6uwZ0nLaLABj2
	 Ly/i51Lug8kHTeKHt0sOEyAEaFq4S0eb4MTCLoZsHoQIebL3w5+kFZd//YQMmGUiXU
	 4WkplG7Ari2A2w0tOQzaO/RkIK0JrHzIWXgmzQyU=
Received: by mail-wr1-f46.google.com with SMTP id b17so2648745wrq.11
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:25:36 -0700 (PDT)
X-Received: by 2002:adf:f2c8:: with SMTP id d8mr4513620wrp.221.1559852734693;
 Thu, 06 Jun 2019 13:25:34 -0700 (PDT)
MIME-Version: 1.0
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-11-yu-cheng.yu@intel.com>
In-Reply-To: <20190606200926.4029-11-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 6 Jun 2019 13:25:23 -0700
X-Gmail-Original-Message-ID: <CALCETrUZ9vu8+9WrMcMdV6DvmB3nRQmLjd5_uDk8x1NMQUtPpg@mail.gmail.com>
Message-ID: <CALCETrUZ9vu8+9WrMcMdV6DvmB3nRQmLjd5_uDk8x1NMQUtPpg@mail.gmail.com>
Subject: Re: [PATCH v7 10/14] x86/vdso/32: Add ENDBR32 to __kernel_vsyscall
 entry point
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

On Thu, Jun 6, 2019 at 1:17 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> From: "H.J. Lu" <hjl.tools@gmail.com>
>
> Add ENDBR32 to __kernel_vsyscall entry point.
>

Acked-by: Andy Lutomirski <luto@kernel.org>

However, you forgot your own Signed-off-by.

> Signed-off-by: H.J. Lu <hjl.tools@gmail.com>


--Andy

