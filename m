Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63FB6C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 19:14:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F7032175B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 19:14:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="jkNJ+Pou"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F7032175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9405C6B0003; Thu, 21 Mar 2019 15:14:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EF746B0006; Thu, 21 Mar 2019 15:14:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 804826B0007; Thu, 21 Mar 2019 15:14:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 609256B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 15:14:57 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id v18so5341907qtk.5
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 12:14:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=//JAeD7GtoYuUnQxyXphyG/RSf+ppIZUIcHmk2Zptdc=;
        b=cKfLAcUI0BMMENTmlHam6+3/SnOfTeuAm3Nm7VzJz9/fGMQ9uPlI1xslp5ayn+pVM0
         nm1t6TCmqimwvxubwWlMp0kQWGenYrbRU7g6IOKf5nMtniKf72wauJ6lhW4zX4WYQrvN
         dVq2ZTo8mmKqDvjydX1lkuhZNE3sBUD2uCvMWyVdT7GI8aUiP1HqyvvxWDfXOcZkxNCx
         BftUo+SRKP36wtIGjAqKzcxEjAIEyPQWlaj4YSA8a817jdxt0nFZnFYIfkwL5wzeWjcs
         ydCdhBX3I/nMpQ2UIycMw1bxCD0Wh9WuTkehX7VERnRChnyxZB+qnNA/AZALWvipoeKG
         W3DA==
X-Gm-Message-State: APjAAAXC1BKyo9H2wRDt6+lMis1JsNWbMv0MbEDhuDMVhC22cL6BL477
	IQhGabYagSscb1yR6etuwOy1Tt3Rd5/YK7Oe+3mECfxjGJ9yd22AcDLludh85VTIcEtvUqyoNGt
	6q5HL1MmTra0rJ+ItT4hh4oepwfEFqOcbXGnIpPSRpgTw/2AsSShyAhtPsOE7cRw/AA==
X-Received: by 2002:a0c:d28f:: with SMTP id q15mr4661098qvh.185.1553195697056;
        Thu, 21 Mar 2019 12:14:57 -0700 (PDT)
X-Received: by 2002:a0c:d28f:: with SMTP id q15mr4661048qvh.185.1553195696438;
        Thu, 21 Mar 2019 12:14:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553195696; cv=none;
        d=google.com; s=arc-20160816;
        b=y+2ll+u/6KWwydsQG1tkKDmVEpJZ4CDpKj6P5IYoTUMwZbfJm0g/FrGhPYrgPYl3kD
         gVYHYmICSJZRK1DsexP4gHqm3ES8jynk7N4jTrF9gMhDdLFpVde5GW6RmTrOYnNEfas9
         7hr7b91aSU/RLJtA6BGGRWBt1JB55Y4vT4tL15elceOW1/ri0Ca+6opD3/82UErjbeZx
         efGs+24Fk61qpM1KD+UAsmoHc0M9++TYxdy2uaSq5nt7xPtDhbSartv/3b7YN3yv2Rev
         SXRbNmGBF522yekmZbIdelAp/tgCzE+XK3+QBc3UL37/K/Y8YGm9svkyQ7AkLzL28wpT
         Rh0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=//JAeD7GtoYuUnQxyXphyG/RSf+ppIZUIcHmk2Zptdc=;
        b=xnfHvXsYVVoSn1Ew5GoEC+OJiVdqjjSz0OrgDYYJLGILnVh4ppO+UNM6J2th0O9x8o
         N4q+drUtCR/CW095TeZQeL+3coOpdq9om5CfnxXV0RLmvPM67uBNKav5G5EM0p4os+0h
         ZS0voXRovfAqnDfPTS2mEdQqkOQ31y0i8IJFhr45QAGAfU4iyQIBJK8DwIYyj+uBNhDU
         wacdC5TdHlpreBb5dYstqR+Disqa45XokBgXrYyNaH86LaJ+Yh3Px43pTafWmzJ45s79
         /gJqJQv4lsr2ljyh+CTHjglwky74BFDcK+H+9S8RvyRzWVIHBLUcju6jDr7SAdR8Xpsi
         RbsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=jkNJ+Pou;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k26sor9764719qtf.56.2019.03.21.12.14.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 12:14:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=jkNJ+Pou;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=//JAeD7GtoYuUnQxyXphyG/RSf+ppIZUIcHmk2Zptdc=;
        b=jkNJ+Pou1iBhC+ww8fO/l9I+ThYww4YUSIzCXDUXaTI6YuZrf0jrngRnuVooMwc+bx
         9TMmolPzAaXWLDwgVr2jVW6lzVrCEirLSqcEDP0PrcquAUnl8gdSKt67Jvl2Yxlj2TJG
         Ic6J8byEIYVn9E3n4nquVUboSRdXmXXMFT3wn8t6gtGxXUid76CX1+K9FbUoL+uxnyM/
         IEu/X8amJU9m07M+gfaBe+mRDcDGzcpe0KPJY3tKONPX7pPVCx4gSMfpqrPeVZdzl5dx
         wbC1I+62j2lD8+Y4M+DxTzfaQIcuXdoEhNTzpOrQVJ9Oq+iWVnriOl5eUPQx+Er385ir
         eKZw==
X-Google-Smtp-Source: APXvYqyRnl90H6dBDlmpYkwXkS82hW7QuX5l8d1SyjPZpxd0TPV3zIpD6QtheWigF02gnpZyVNN2XA==
X-Received: by 2002:ac8:34a2:: with SMTP id w31mr4777475qtb.164.1553195696027;
        Thu, 21 Mar 2019 12:14:56 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id k12sm4067929qti.38.2019.03.21.12.14.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 12:14:55 -0700 (PDT)
Message-ID: <1553195694.26196.20.camel@lca.pw>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
From: Qian Cai <cai@lca.pw>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, 
	mgorman@techsingularity.net, vbabka@suse.cz
Date: Thu, 21 Mar 2019 15:14:54 -0400
In-Reply-To: <CABXGCsMQ7x2XxJmmsZ_cdcvqsfjqOgYFu40gTAcVOZgf4x6rVQ@mail.gmail.com>
References: 
	<CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
	 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
	 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
	 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
	 <1553174486.26196.11.camel@lca.pw>
	 <CABXGCsM9ouWB0hELst8Kb9dt2u6HKY-XR=H8=u-1BKugBop0Pg@mail.gmail.com>
	 <1553183333.26196.15.camel@lca.pw>
	 <CABXGCsMQ7x2XxJmmsZ_cdcvqsfjqOgYFu40gTAcVOZgf4x6rVQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-03-21 at 23:57 +0500, Mikhail Gavrilov wrote:
> On Thu, 21 Mar 2019 at 20:48, Qian Cai <cai@lca.pw> wrote:
> > OK, those pages look similar enough. If you add this to __init_single_page()
> > in
> > mm/page_alloc.c :
> > 
> > if (page == (void *)0xffffdcd2607ce000 || page == (void *)0xffffe4b7607ce000
> > ||
> > page == (void *)0xffffd27aa07ce000 || page == (void *)0xffffcf49607ce000) {
> >         printk("KK page = %px\n", page);
> >         dump_stack();
> > }
> > 
> > to see where those pages have been initialized in the first place.
> 
> In the new kernel panics "page" also does not repeated.
> 
> $ journalctl | grep "page:"
> Mar 21 20:46:56 localhost.localdomain kernel: page:fffffbbbe07ce000 is
> uninitialized and poisoned
> Mar 21 21:28:03 localhost.localdomain kernel: page:ffffdecc207ce000 is
> uninitialized and poisoned
> Mar 21 23:43:24 localhost.localdomain kernel: page:fffff91ce07ce000 is
> uninitialized and poisoned

That is OK. The above debug patch may still be useful to figure out where those
pages come from (or you could add those 3 pages address to the patch as well).
They may be initialized in a similar fashion or uninitialized to begin with.

