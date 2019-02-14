Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 682DBC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 09:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24018222A4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 09:11:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lXo5CZBL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24018222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B45B48E0002; Thu, 14 Feb 2019 04:11:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF8E38E0001; Thu, 14 Feb 2019 04:11:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E60B8E0002; Thu, 14 Feb 2019 04:11:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 724EF8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 04:11:40 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id r133so1255659vsc.3
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:11:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eFBWiFIaqtau2CVEYcyX/n7Z0Eb/ey9J9D6DfDHhgzs=;
        b=YBgmMK4hHjegiMP/3GdYLUCr1chfl1AGz5KMyfAy2JOM+fzgtispUgKfrWDSm8eLKz
         X2mR276GHZz5pfABKHB80IZyz0k+ON7efHYHLnACO+kRxA2qeh+lznxnj7BJDAeQ9oqL
         rdjII8SnA1UhYVKiIAUxR2nOicYxGkBNMQA9lqUuvzBuq+8DiDuOCCQxHib7rqmriABU
         p2awXxmoN6KbIqX/XpF5eUxlRAKpvDJn6WzyqapDeber9uNR4CQtBr/RGPDO6+ml4FnW
         HbVWzNbathX2VJle/0jUyCPwK92wxuSo86cjhpOwHlZJNgTq9bLSu7VbtaetNJN/MwYG
         cyuw==
X-Gm-Message-State: AHQUAuY2s1fKnjki7DcR/OWqcv0Akn4E+YvmGEfhzA6Eu9OK+83oW+uT
	SfZPo6XV1lSKlE3RLbTD66duL36TDzuyvep1UFaUbh/vSxwbbV6dxAVZF0sRi/OY7317cYBOyN4
	g22lEcAatg+daZBJtVZopJc4WbrwFdyhaNfcVtqrETszueLey+pvXP9xj7YyIutIqZ2p4CjXjsj
	saq0XoMaYVmI7gqH3EV0avMPsHxoPueoWWZ95O3FbF9EEYuvDsJDeg2HnxMuszcaBRepszwnwK7
	sygiPelzC0r0bBm83bb2luD8Q2Dj7gtXBd39YOMM/6eNOaCNL7Do4L7nJc+xSl5r0BZiDWZlFWz
	7yBPjhNrh14sc6lppzm9/K/tCdqHqCSsWzAp0SPNDdLV5L58EcZWMyL1MaT3VS/AnOXl2O9v+kw
	/
X-Received: by 2002:ab0:7259:: with SMTP id d25mr1395065uap.129.1550135500080;
        Thu, 14 Feb 2019 01:11:40 -0800 (PST)
X-Received: by 2002:ab0:7259:: with SMTP id d25mr1395043uap.129.1550135499344;
        Thu, 14 Feb 2019 01:11:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550135499; cv=none;
        d=google.com; s=arc-20160816;
        b=XsffMd64RDt+vaqES5xL0s1Xk+oR8j8K3VVVa4/j8OaDmg8S4HzxNVwfjHfih1jttZ
         zYQ36kvuAsu4hWJzVfJn6BLVjY0a75C8OlvaYLH2jknxMfnH3bwvLPZl4d/ebIuQ3d3M
         X4pC48AoHI0oUCZWEsb0Btr0ZIdbmQCoZt7tH7Ui+kE76dIC9SpJOzZTzMtYGYNSSwek
         JbnMbIjOddcYdU1GHO69vugfQ3sF9ecRybJ6gPb6C+RelLawEpt7ATz6aik4ltwzKHYO
         AD/SnqTFBcrTOQ6f048tp1mLlWLIZiI8eGoNjZwC7LKaiE22WBcYScMmelE3umQ65bkv
         tHCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eFBWiFIaqtau2CVEYcyX/n7Z0Eb/ey9J9D6DfDHhgzs=;
        b=N1uoTYUqu74CQSa5Map+XQksEEjjJ0NqHWePOe24hMwu60pJafpYKYb+xfF8OGCTyN
         hY2SCyq9dI2PycIMJDT0kvAFhCmIYbhpyqYnXfQSlX9Xhk2upWtWtkszHBSgha/w25al
         OD+TyqfKh2/m4VAMphd5Q6qjmX+jcRJDarLkq/DQ/Ot1/LE7+IPsdWjDaorswrAyKvOp
         cy4ZX7fNtxDUb3RQUpIC5A24FWY8A1OHUO7rZhUfsCqswIEJIwwwTdv3CE2ro8IzfmSf
         VCEQX9b7/Zltwyvp6p5U5eSU+bImqyFAp0L01Im4UcJjJnQwFbAyiBuJ4GcIx2q2imlT
         6jZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lXo5CZBL;
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e68sor975518vsd.92.2019.02.14.01.11.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 01:11:39 -0800 (PST)
Received-SPF: pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lXo5CZBL;
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eFBWiFIaqtau2CVEYcyX/n7Z0Eb/ey9J9D6DfDHhgzs=;
        b=lXo5CZBLyz09qu2yMefNbmTEv9ODDQ63Nr7/pO7A4Tfecbc8tRWL0VO+sjk1MMVIGV
         Pds4mYWbdz5Z3vXKWVHOasiXWH5oTdLG1Yacn+Vt89SaidIlI+NVDGiUVAOrMYA4t79W
         XwLkB4KhGd3mHKZcJf6J7zN9Zma8ycIZPSSD9X6M4yz4zQf2QrqzUYKU7Wzt7VZU49zz
         xvC6XXilhC1UZM4c4WhkZoTLMVgs9nHPw+krMkylz/E/e0/lII6yEm1mU0PV4fN6awyJ
         m+d43bDfjZtclBp7d2MIZiuaYj/ygrn+8umOK/6hviZ3uZsSkxINGXloPRjHIwl/fU+w
         gT5w==
X-Google-Smtp-Source: AHgI3Ia2bkMipgD+6KUp7PEUN+/FFL4FgtPyWHqMV1yVk97wsZcM/zTPsglMQF1pQ+Yk1LKK6+59/ArfIyaM4ujlVTo=
X-Received: by 2002:a67:edca:: with SMTP id e10mr1418794vsp.196.1550135498946;
 Thu, 14 Feb 2019 01:11:38 -0800 (PST)
MIME-Version: 1.0
References: <CAOuPNLgaDJm27nECxq1jtny=+ixt=GPf2C7zyDsVgbsLvtDarA@mail.gmail.com>
 <6183c865-2e90-5fb9-9e10-1339ae491b71@codeaurora.org> <CAOuPNLgUvECE6XBjszFggY3efmEBKywzKNWupjfQ2svsCMqd7w@mail.gmail.com>
 <2c91af7d-4580-cedc-70ea-d38c2587c7bf@codeaurora.org>
In-Reply-To: <2c91af7d-4580-cedc-70ea-d38c2587c7bf@codeaurora.org>
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Thu, 14 Feb 2019 14:41:27 +0530
Message-ID: <CAOuPNLip6rwxC1DdDiCb28d5+uJNE9=ThCn+rjac854GkcnedA@mail.gmail.com>
Subject: Re: BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:65
To: Sai Prakash Ranjan <saiprakash.ranjan@codeaurora.org>
Cc: open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, 
	linux-rt-users@vger.kernel.org, linux-mm@kvack.org, 
	Jorge Ramirez <jorge.ramirez-ortiz@linaro.org>, 
	"Xenomai@xenomai.org" <xenomai@xenomai.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Sai,

Thanks so much for your help.

On Thu, Feb 14, 2019 at 12:14 AM Sai Prakash Ranjan
<saiprakash.ranjan@codeaurora.org> wrote:
>
> Hi,
>
> On 2/13/2019 8:10 PM, Pintu Agarwal wrote:
> > OK thanks for your suggestions. sdm845-perf_defconfig did not work for
> > me. The target did not boot.
>
> Perf defconfig works fine. You need to enable serial console with below
> config added to perf defconfig.
>
> CONFIG_SERIAL_MSM_GENI_CONSOLE=y
>
Actually for me the kernel does not boot. It stuck in bootloader, with
"valid dtb not found".
I did not debug it further.
Anyways, we can look into this issue later.

> > However, disabling CONFIG_PANIC_ON_SCHED_BUG works, and I got a root
> > shell at least.
>
> >
> > But this seems to be a work around.
> > I still get a back trace in kernel logs from many different places.
> > So, it looks like there is some code in qualcomm specific drivers that
> > is calling a sleeping method from invalid context.
> > How to find that...
> > If this fix is already available in latest version, please let me know.
> >
>
> Seems like interrupts are disabled when down_write_killable() is called.
> It's not the drivers that is calling the sleeping method which can  be
> seen from the log.
>
> [   22.140224] [<ffffff88b8ce65a8>] ___might_sleep+0x140/0x188
> [   22.145862] [<ffffff88b8ce6648>] __might_sleep+0x58/0x90         <---
> [   22.151249] [<ffffff88b9d43f84>] down_write_killable+0x2c/0x80   <---
> [   22.157155] [<ffffff88b8e53cd8>] setup_arg_pages+0xb8/0x208      <---
> [   22.162792] [<ffffff88b8eb7534>] load_elf_binary+0x434/0x1298
> [   22.168600] [<ffffff88b8e55674>] search_binary_handler+0xac/0x1f0
> [   22.174763] [<ffffff88b8e560ec>]
> do_execveat_common.isra.15+0x504/0x6c8
> [   22.181452] [<ffffff88b8e562f4>] do_execve+0x44/0x58
> [   22.186481] [<ffffff88b8c84030>] run_init_process+0x38/0x48      <---
> [   22.192122] [<ffffff88b9d3db1c>] kernel_init+0x8c/0x108
> [   22.197411] [<ffffff88b8c83f00>] ret_from_fork+0x10/0x50
>
Yes, these are generic API, and I don't expect any changes in here.
We don't have this issue in another SOC 4.9 kernel.
Also I compared these APIs with mainline and there is no major changes here.
This is just one example.
This sleep issue is happening from other places as well.
May be one common similarity may be: during task loading, or switching.

>  >
>  > This at least proves that there is no issue in core ipipe patches, and
>  > I can proceed.
>
> I doubt the *IPIPE patches*. You said you removed the configs, but all
> code are not under IPIPE configs and as I see there are lots of
> changes to interrupt code in general with ipipe.
>
We observed that this issue is happening in normal sdm845 kernel as
well (without ipipe/xenomai patches applied in another branch).
Another point is, we don't see this issue in another arm64 target such
as hikey, with same 4.9 kernel.

> So to actually confirm whether the issue is with qcom drivers or ipipe,
> please *remove ipipe patches (not just configs)* and boot.
> Also paste the full dmesg logs for these 2 cases(with and without
> ipipe).
>
hmmm. This will be little tough.
I will try to find sometime to point the exact cause, and share findings here.
Currently, I am debugging another issue.

Thanks for your help.


Regards

