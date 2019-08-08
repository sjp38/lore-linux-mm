Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C12C3C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 12:46:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AB31217D7
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 12:46:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="DHc3hfWr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AB31217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D98026B0003; Thu,  8 Aug 2019 08:46:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D213F6B0006; Thu,  8 Aug 2019 08:46:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0F946B0007; Thu,  8 Aug 2019 08:46:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 884286B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 08:46:58 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id ci3so12846989plb.8
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 05:46:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8nd7iiRR2uDJxy8k3TMvF7GQaePD1T7jKUgr9+0/pqE=;
        b=J9PSHp9w9ZV6d1JVM7JIIkKWFmeDHDF4BLh3H85uSw9Lv9BJGHSCl9LNxjjIHuCPNE
         QOLvIgO+w59IGU6Q/pXZnKCAAL6/+hYjEx3m2Rs8vBxWeSVd8evjhTFVoSvpNOWgCPwp
         ywulhUwmQSwceQEAx0xR/NJ9UoLay5Tjt3Gt7J77T0SPxIWJMhVuPey2FQOZFxPV1RHA
         qOZeKRQxzZmFH/c/OeUTei54yHzfV1I2MQPF8MvJUR6qu0XSHF16YxeUl72zazwGMpJX
         FAx1Bukdqq9FLNoXEx3ww4hYXanzeRfQYr7PmbR8pKSSs10tmbIhuhf5bcgKhuN992oJ
         Blgg==
X-Gm-Message-State: APjAAAVxVrQMXuvr4iGhmvjTOuJMVdyA2s8oI1YClgY5I08dnCqKjh4l
	UAzaNeyLiDTpQOhf2hrGA/c3a2eNPItVjYdudq88RR4neP53owZp2bcNaLduUub68FsO3hdltGV
	DuaVcIYChoUrQXxKSZgyKvhI1ddP22QxXkT3oUeV+rgx9TeFNpqbP54invBIyb2mv6A==
X-Received: by 2002:a63:f04:: with SMTP id e4mr11660334pgl.38.1565268417795;
        Thu, 08 Aug 2019 05:46:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUlSnEYMebBSd8TDtS4B6LGiBg6477e5OzH9aObIEGixfL9FI0zOKWxh4MzlLcKrfEM4I2
X-Received: by 2002:a63:f04:: with SMTP id e4mr11660286pgl.38.1565268416809;
        Thu, 08 Aug 2019 05:46:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565268416; cv=none;
        d=google.com; s=arc-20160816;
        b=IUhcd4cVV6MREbD3W+JW+ivo6kxWZZKraZpivuZ1MwySar/om0p5kpM4WPzMYxydXA
         Hrmtx1Pd11mx19CYDkWdvb0S1IoxF3MuNb97dNwHSi11THDJ46veZlVLEkrvwGICNJeL
         1wwefU+7cz66jdTFDZbBbMSLliq+B372niA07hsn6Obnmlff1dHMALVXq2AKGYyYsQhL
         lmM67IGYwlSONXrFBeYXXO7y476vi/2fuoAMeyo7qt4YVnvAIp4Yv2NiPGnhhFa847T0
         je2/z/KMQ8xQC0xn38OVmpa2UGKKP1/M0pfBjWZM4MPrys77uUOOcyQXPXczPmIULyZY
         mQ/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8nd7iiRR2uDJxy8k3TMvF7GQaePD1T7jKUgr9+0/pqE=;
        b=xBUGYLdgekVhXoAAEwb7/UYeVwe4QMsfZzZf+ZJpCyLdqbDkLN2ogjICglzSXzZNNW
         /+UekBsgTxNYz8yR3DA7APxs3XdG7tQG+6c9AYuWeOQZulk66w55ino20V50jBR0ryDV
         IzGPpiEy/Z0l58ARqcH3ANIu51FSGUgJQ+SmEebskqQJLgT8TZjmLwXoA+SHNznZrvwD
         VhlewLhE6qKEPoKxZeAN5KNDEckamTL5SuWfC8uLpUcU9ZWn5ZfnhwQVei4Vl32PI20y
         Ama8sQxeKjuEWiJU2seSSrQF8jJhdHl5MU7C8/fsLX3VbPkyuc6XTc/672Y1pEVDIG+v
         PNNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DHc3hfWr;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t9si1845440pji.69.2019.08.08.05.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 05:46:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DHc3hfWr;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CA5FA2171F;
	Thu,  8 Aug 2019 12:46:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565268416;
	bh=K4KvFbUOjG4sKLOZlXNsxRufBtA9Jpgu03DPyml6ddU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=DHc3hfWr4bSGlQa/A+RlbktFUpzSLW9GPuQTZz+6DFTeL0IPl6c3JKu4pGx2SI7Kg
	 sf/8g3CF0hFbFXstDKmpYfiw8U2q1QD71McN3tHjxydMbjjGjNXwUZ1SBOy9BMhNAy
	 Zn6q81aHbBGVhGcalPXQPTnpnUYNokYiD7ymf3K8=
Date: Thu, 8 Aug 2019 14:46:54 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: syzbot <syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com>,
	Michael Hund <mhund@ld-didactic.de>
Cc: akpm@linux-foundation.org, andreyknvl@google.com, cai@lca.pw,
	keescook@chromium.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-usb@vger.kernel.org,
	syzkaller-bugs@googlegroups.com, tglx@linutronix.de
Subject: Re: BUG: bad usercopy in ld_usb_read
Message-ID: <20190808124654.GB32144@kroah.com>
References: <0000000000005c056c058f9a5437@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000005c056c058f9a5437@google.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 05:38:06AM -0700, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    e96407b4 usb-fuzzer: main usb gadget fuzzer driver
> git tree:       https://github.com/google/kasan.git usb-fuzzer
> console output: https://syzkaller.appspot.com/x/log.txt?x=13aeaece600000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=cfa2c18fb6a8068e
> dashboard link: https://syzkaller.appspot.com/bug?extid=45b2f40f0778cfa7634e
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> 
> Unfortunately, I don't have any reproducer for this crash yet.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com
> 
> ldusb 6-1:0.124: Read buffer overflow, -131383996186150 bytes dropped

That's a funny number :)

Nice overflow found, I see you are now starting to fuzz the char device
nodes of usb drivers...

Michael, care to fix this up?

thanks,

greg k-h

