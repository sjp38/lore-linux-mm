Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 658BDC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:13:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 272E420880
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:13:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 272E420880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFEA48E001C; Tue, 29 Jan 2019 14:13:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAD338E0001; Tue, 29 Jan 2019 14:13:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC31D8E001C; Tue, 29 Jan 2019 14:13:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7774F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:13:49 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 82so17643494pfs.20
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:13:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tuxdH+kVi5Dz/1pinkMuDnwEekkTtsXCB5BZAf+G2f4=;
        b=S8H/kWabk57Q7DQOQPqUyniVytODolIseclgWWQ+2Aoq0GuhpeYfU1cR91av2bOsPs
         QJPHJzUtS4Iz6lq9OkNNqMLuwfSYI3CD5JR4KYLoG3+kI4YuS259kOvPkPfaed3xZ3D3
         ejj8z1Kwuk7B5/G7DdkUEPY2qFFzdZ2MWvAhe34ngdsaDJOx8YWwgNu1yL1sbzjuT3xt
         2zy3KbFfW9lGgkNRT4heEu9wL2qsFfOLOn+DAvV9pV0f9nI7N6YAybLjY8OnS3hZP13o
         8ZC8+svd9NQOXbadjkx3uq56ZiwsMdUAXQn+6rI0guKlWwAYJD0x32Vr4DsLWdEdLngY
         a5lw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukefMeIevoJrVzpXDeyA27QaNZ/32hkx2QfA9FS6KuPXrFk86P8d
	Q5da+eyvKhBt8Cwki4/L+IJnRVnBxEiTMadU77H9vHKxFhBzxmFmgcG4fLk69qJiuPeYR+Jfyim
	POXxgt/Vz1Umcwj1RR1fGxnwxrt+iKWCIzeDas/qv2b+zA1nNoUo8vM6l5niC4RylAg==
X-Received: by 2002:a17:902:bd0b:: with SMTP id p11mr27482758pls.259.1548789229157;
        Tue, 29 Jan 2019 11:13:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN69d2a+INOc1LLzyVu7RPIfQc2GxeCEpYNtRZezx+DITFFrxZ5W6G6UOweSp14zRPrLASQ+
X-Received: by 2002:a17:902:bd0b:: with SMTP id p11mr27482714pls.259.1548789228493;
        Tue, 29 Jan 2019 11:13:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548789228; cv=none;
        d=google.com; s=arc-20160816;
        b=N3rGGfl7rufaAxlcTuL6ZSA3yhp/qlK2RttJ9bYEJeVt1yfovNQjyHPxKLgMQ3Zxvf
         p5eL4upBz8TYLoOqlx3eV0/IhuT9Ib7Dsa9tnFtehD32DYWzkfN3TCkTX9VaNUskvw11
         lEq3aoCE/YCP7052QGoPZxVRhToJtKjLi/W+y6qmAmbO4KffF54wLeMeyN/24mSDq2nB
         Oj4SyKouOK9Eg2TVd5vrZNj0v4QMaIaM8sIjB+YgC0MczWV1ut20+oRwLh9BTUDvkcYq
         1ePCoZh4XxYpoJxJn4bYtp3JwwyfuZql/5kasZ43+PpUJHGeEzeMqB6QTAbW7WfzXHvz
         yU6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=tuxdH+kVi5Dz/1pinkMuDnwEekkTtsXCB5BZAf+G2f4=;
        b=RSHDI4zMzKZRU7//WpDcQAOjpkZnj3iAo7uGBK/6tG1c/rSu2FW81EhkPpvy5mXeO/
         e+mUWefe71J7NX1G26IfMQyrKCQ3fTX6Nm+N/xvfrfDqnyIEvUG/BiLl6Bq0IGONFkST
         3z6PC4neBBBuhOQmM/LBCbBVkewbPfwbsb+SSUpjc7FMN/BJbBhckUAgqlGLPZQUXjki
         GliZkXF6jk6yo5khMWGZuCVYQTCwr3o1Zz499WiO/0qEtbWn+CLi4WHNueDTafGM3xeK
         w5bSQ//nuuackecccgMt4zZyt/FAC9xxu5gz2pJsyZMpCn63vlq+dGo9so48Av+nGcKa
         Tx7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o28si37270650pgm.238.2019.01.29.11.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:13:48 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id BF6C73006;
	Tue, 29 Jan 2019 19:13:47 +0000 (UTC)
Date: Tue, 29 Jan 2019 11:13:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Jiufei Xue <jiufei.xue@linux.alibaba.com>, linux-mm@kvack.org,
 joseph.qi@linux.alibaba.com
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
Message-Id: <20190129111346.fbb11cc79c09b7809f447bef@linux-foundation.org>
In-Reply-To: <132b9310-2478-19e1-aed3-48a2b448ca50@I-love.SAKURA.ne.jp>
References: <20190129072154.63783-1-jiufei.xue@linux.alibaba.com>
	<132b9310-2478-19e1-aed3-48a2b448ca50@I-love.SAKURA.ne.jp>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2019 20:43:20 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> On 2019/01/29 16:21, Jiufei Xue wrote:
> > Trinity reports BUG:
> > 
> > sleeping function called from invalid context at mm/vmalloc.c:1477
> > in_atomic(): 1, irqs_disabled(): 0, pid: 12269, name: trinity-c1
> > 
> > [ 2748.573460] Call Trace:
> > [ 2748.575935]  dump_stack+0x91/0xeb
> > [ 2748.578512]  ___might_sleep+0x21c/0x250
> > [ 2748.581090]  remove_vm_area+0x1d/0x90
> > [ 2748.583637]  __vunmap+0x76/0x100
> > [ 2748.586120]  __se_sys_swapon+0xb9a/0x1220
> > [ 2748.598973]  do_syscall_64+0x60/0x210
> > [ 2748.601439]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > 
> > This is triggered by calling kvfree() inside spinlock() section in
> > function alloc_swap_info().
> > Fix this by moving the kvfree() after spin_unlock().
> > 
> 
> Excuse me? But isn't kvfree() safe to be called with spinlock held?

Yes, I'm having trouble spotting where kvfree() can sleep.  Perhaps it
*used* to sleep on mutex_lock(vmap_purge_lock), but
try_purge_vmap_area_lazy() is using mutex_trylock().  Confused.

kvfree() darn well *shouldn't* sleep!

