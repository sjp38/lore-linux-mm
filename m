Received: by zproxy.gmail.com with SMTP id k1so368221nzf
        for <linux-mm@kvack.org>; Tue, 04 Oct 2005 02:49:29 -0700 (PDT)
Message-ID: <aec7e5c30510040249x7246284fv26e1f281a690a087@mail.gmail.com>
Date: Tue, 4 Oct 2005 18:49:29 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 07/07] i386: numa emulation on pc
In-Reply-To: <20051004.165216.94769788.taka@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
	 <20050930073308.10631.24247.sendpatchset@cherry.local>
	 <20051004.165216.94769788.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: magnus@valinux.co.jp, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 10/4/05, Hirokazu Takahashi <taka@valinux.co.jp> wrote:
> It seems like you've forgot to bind cpus with emulated nodes as linux for
> x86_64 does. I don't think it's your intention.

True, not my intention. I will have a look at that. Thanks.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
