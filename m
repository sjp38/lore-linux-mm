Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E77B8C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:41:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A438020835
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:41:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r/PaWOEg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A438020835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 423ED8E0003; Wed, 13 Feb 2019 09:41:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D2718E0001; Wed, 13 Feb 2019 09:41:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 274608E0003; Wed, 13 Feb 2019 09:41:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC93F8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:41:07 -0500 (EST)
Received: by mail-vs1-f69.google.com with SMTP id u29so611620vsj.1
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:41:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=A83HwLkscd+n/ThJxRWxJ32yY+Lg5D0jBF/2KpDB3qY=;
        b=saGsTPCFw1EnaHyumDt+adJgbCtygljnl4KN/aN/ZaU4a5+S/9JJSYRBnt5vxhnIMn
         ipvstywIu+lnTrMkwlxORPkh6psvpZmoBYh9c8aS+643zDhAGy4ChVYbec4OhycLd0bT
         IIWIFLADvSPGDN/o8lyKtQHJBRuzYEB9+x+1GZ9jb5LDa/zisTPmKMA/d7t5swhh1E1P
         vI4LDGBblml2sE2u8q3TAGe7ft5lZHki6aIdYHBe2PTuaPIVfny9YFRc8cds9teMqgmI
         pdmgXyUM3gDNtUXZksJHBz6GKKd/jAuyZB4YJDdTWeFF0PDt7hVngvApABfzNQcGxRqD
         lidA==
X-Gm-Message-State: AHQUAubx0Rztf5GlOFyNBLMGNIVt0H4F+v5SymNv7B1DHd+lf/Cibl87
	EYLCtcMSSfTMm1GgcVvBG0V3iyZgpMth3TjkX5GM880WkS2wOTM/Sr8kwbCeypRf4NfL6II/OLC
	cZWkI3K58+jndwCw97bYpxm3GqwFzIkoorpyXuZPYrK3bKAqGS+BgIV60a6gBZ9WXt6Acy0Oo3N
	QYMUrYfVf4/+xpki6TSelt2N64DLvYBwkSDaJBFmMghHB3qhc2klH5GhyzeStnnEbpI5VTTj/UE
	mwzrkoCfXEIUEsXJEtOGadBeLaj8n9rRMYbFh42+J6zhQQm84gdKUv09RiSXu6C6QAnYBm715co
	TdukX0nLakYxl5/a2qDFjI3WzqOz6pLhBAiptXblOR+23KrvfYg8gFt/iP02HeAsHnnv/YPzhFq
	0
X-Received: by 2002:ab0:498d:: with SMTP id e13mr325027uad.134.1550068867594;
        Wed, 13 Feb 2019 06:41:07 -0800 (PST)
X-Received: by 2002:ab0:498d:: with SMTP id e13mr325011uad.134.1550068866804;
        Wed, 13 Feb 2019 06:41:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550068866; cv=none;
        d=google.com; s=arc-20160816;
        b=rhQowEDi5va3hW+VlZHcr2tAnLgzY4CmtfU4PE5i2XZQHH3HM5rN/KsNF7x4c5wmiq
         CVB9pmg3DmhD6bzvMfmvVXlGIl3AiXxpy4paoCMT2MSmdBQgTbPNdEmgb28XJ7uaNlAc
         kZ714K7jtlX4m4VgkLOMUG0jxGN74QxLx3x96izE0rM8WFEeo6Xdd4asOLkzVJikS20m
         6E1TB0CgvCFqgp8ICEhVcrrjBKYNUh6te7CXQDR5uYaMmzwEpBKkrq9zEZtXgBhXXC0O
         RragXIn4GpwEDWl7xXpo+mp2oHH1aqpX3/Y4HTjdE0+H4FHLiwVSfJiBnSy8t0mjVw3q
         3Uag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=A83HwLkscd+n/ThJxRWxJ32yY+Lg5D0jBF/2KpDB3qY=;
        b=vgv7s3UrlKvgqBjLVKk/cXbSAHm3clOkmpPgkQdEVm0s4kY4kPIb15/MTboVjK9T8L
         b82hlX3LHo5sXCNXgUbCHR+PHWF5R80o81biSDtUP6A/pKY4T6elnK88EOPm04povaSV
         hjangTnJvzpypXUHsEyienbUMtebxcIS1kfjj53C6VSepwjVOw5SMqci2n8sgQydaBQu
         KBxY4S8yawnBTMCOVNZ+d3MoFs7k41rJgu0feVPniG0vH8UccrHxZ76U1/hClZCQMfAS
         l5S8Iwp9pzlVrniT+mhPl2XjxiqmwFjP1MagbOdJtX5pAB+9dXEXEMHzScUKI+deNjc6
         1wNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="r/PaWOEg";
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o2sor8877820ual.30.2019.02.13.06.41.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 06:41:06 -0800 (PST)
Received-SPF: pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="r/PaWOEg";
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=A83HwLkscd+n/ThJxRWxJ32yY+Lg5D0jBF/2KpDB3qY=;
        b=r/PaWOEgaZqRchY5b+f2Aqpg3NUrIWco/uoRwXLcLhwB8B5qxyiDnFz9uo/U11TGio
         DLiYX102zjFQJuOVt+VmeaDlP9sWXmdSM0sr4W8/95cKua5UW4jLkzRmx0GNOJh3cXHp
         Smkp6lUiv/O9736wsh1aY7pkMqcaJlNMKV5puOBAk0lQUBjCbKz5NS5TwmBxg8kA5+SW
         ecmblUU10D37/LSTNzre+sDf3PpicU9xKYrlfz3vDLgu7Rx6bpBhPGlCgg7WFntkxPcn
         ZENXkhbUqyCnPm24fUhWVa3nqsxNXr8tPIES5eAJIhnAdyN9ioZcYclnNgOKi+RX2+PD
         qqyg==
X-Google-Smtp-Source: AHgI3Ia8V3vK8w1HHishMyZgGE6WARkR4czKUI8KdC5YbgaGPvh4Jl4j9OCo3NSLG+r2yx7/j4YxjsW/FIswodfTXps=
X-Received: by 2002:ab0:5a71:: with SMTP id m46mr316889uad.123.1550068866332;
 Wed, 13 Feb 2019 06:41:06 -0800 (PST)
MIME-Version: 1.0
References: <CAOuPNLgaDJm27nECxq1jtny=+ixt=GPf2C7zyDsVgbsLvtDarA@mail.gmail.com>
 <6183c865-2e90-5fb9-9e10-1339ae491b71@codeaurora.org>
In-Reply-To: <6183c865-2e90-5fb9-9e10-1339ae491b71@codeaurora.org>
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Wed, 13 Feb 2019 20:10:55 +0530
Message-ID: <CAOuPNLgUvECE6XBjszFggY3efmEBKywzKNWupjfQ2svsCMqd7w@mail.gmail.com>
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

On Wed, Feb 13, 2019 at 3:21 PM Sai Prakash Ranjan
<saiprakash.ranjan@codeaurora.org> wrote:
>
> Hi Pintu,
>
> On 2/13/2019 2:04 PM, Pintu Agarwal wrote:
> >
> > This is the complete logs at the time of crash:
> >
> > [   21.681020] VFS: Mounted root (ext4 filesystem) readonly on device 8:6.
> > [   21.690441] devtmpfs: mounted
> > [   21.702517] Freeing unused kernel memory: 6528K
> > [   21.766665] BUG: sleeping function called from invalid context at
> > kernel/locking/rwsem.c:65
> > [   21.775108] in_atomic(): 0, irqs_disabled(): 128, pid: 1, name: init
> > [   21.781532] ------------[ cut here ]------------
> > [   21.786209] kernel BUG at kernel/sched/core.c:8490!
> > [   21.791157] ------------[ cut here ]------------
> > [   21.795831] kernel BUG at kernel/sched/core.c:8490!
> > [   21.800763] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> > [   21.806319] Modules linked in:
> > [   21.809474] CPU: 0 PID: 1 Comm: init Not tainted 4.9.103+ #115
> > [   21.815375] Hardware name: Qualcomm Technologies, Inc. MSM XXXX
> > [   21.822584] task: ffffffe330440080 task.stack: ffffffe330448000
> > [   21.828584] PC is at ___might_sleep+0x140/0x188
> > [   21.833175] LR is at ___might_sleep+0x128/0x188
> > [   21.837759] pc : [<ffffff88b8ce65a8>] lr : [<ffffff88b8ce6590>]
> > pstate: 604001c5
>
> <snip...>
>
> > 0000000000000000 ffffffe33044b8d0
> > [   22.135279] bac0: 0000000000000462 0000000000000006
> > [   22.140224] [<ffffff88b8ce65a8>] ___might_sleep+0x140/0x188
> > [   22.145862] [<ffffff88b8ce6648>] __might_sleep+0x58/0x90
> > [   22.151249] [<ffffff88b9d43f84>] down_write_killable+0x2c/0x80
> > [   22.157155] [<ffffff88b8e53cd8>] setup_arg_pages+0xb8/0x208
> > [   22.162792] [<ffffff88b8eb7534>] load_elf_binary+0x434/0x1298
> > [   22.168600] [<ffffff88b8e55674>] search_binary_handler+0xac/0x1f0
> > [   22.174763] [<ffffff88b8e560ec>] do_execveat_common.isra.15+0x504/0x6c8
> > [   22.181452] [<ffffff88b8e562f4>] do_execve+0x44/0x58
> > [   22.186481] [<ffffff88b8c84030>] run_init_process+0x38/0x48
> > [   22.192122] [<ffffff88b9d3db1c>] kernel_init+0x8c/0x108
> > [   22.197411] [<ffffff88b8c83f00>] ret_from_fork+0x10/0x50
> > [   22.202790] Code: b9453800 0b000020 6b00027f 540000c1 (d4210000)
> > [   22.208965] ---[ end trace d775a851176a61ec ]---
> > [   22.220051] Kernel panic - not syncing: Attempted to kill init!
> > exitcode=0x0000000b
> >
>
> This might be the work of CONFIG_PANIC_ON_SCHED_BUG which is extra debug
> option enabled in *sdm845_defconfig*. You can disable it or better
> I would suggest to use *sdm845-perf_defconfig* instead of
> sdm845_defconfig since there are a lot of debug options enabled
> in the latter which may be not compatible when IPIPE patches
> are applied.

OK thanks for your suggestions. sdm845-perf_defconfig did not work for
me. The target did not boot.
However, disabling CONFIG_PANIC_ON_SCHED_BUG works, and I got a root
shell at least.
This at least proves that there is no issue in core ipipe patches, and
I can proceed.

But this seems to be a work around.
I still get a back trace in kernel logs from many different places.
So, it looks like there is some code in qualcomm specific drivers that
is calling a sleeping method from invalid context.
How to find that...
If this fix is already available in latest version, please let me know.

Thanks,
Pintu

