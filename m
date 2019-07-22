Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47579C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 14:11:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08D8121911
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 14:11:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="AqJLL2tA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08D8121911
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98A196B0005; Mon, 22 Jul 2019 10:11:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 913678E0003; Mon, 22 Jul 2019 10:11:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8023A8E0001; Mon, 22 Jul 2019 10:11:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE736B0005
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 10:11:55 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id h198so33762897qke.1
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 07:11:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LtBWSYY5RJyJ5bjGuD8GT1ULGrE6M+cxt5l8yU6kpN0=;
        b=n78V6gH2keybtEufjcxJKPUG08DxGk5rv5HB0igPuOUDCOgI4DuNf6IeGIrK3/umR5
         cmG8aa4tV+3N/HiJ8CCsdyFfFF1t7Oyj73X8GiL+YSfiqjXDnOlc0ai8px0RCu+XB6AM
         ZQ2ZyyLXnzKTsM10p14O29CSTVmwdO7JW2zfB88yMLsju9fnCdmZsRhN20bkmXLk1gg8
         jHIpZshvi6BNYKEIGdELw9VGj1YbFs+8lkoMBnnZWeqZL+3dElSky8G+gk6rwyFdvOQO
         klseHgHG2mnjlxb/jK9wfLITJ3P0f8/6bcZWBA2v6HlXJRQofvlJ8BvfrTm0fty5hiTx
         CZYg==
X-Gm-Message-State: APjAAAUQn35PUDrrpQo0yV5AlQV5hCbLXaVVKbzo/FhDvptFLsFWFy50
	eqlndQLXc/1PkaCLJP6tTWsFyzeAbes/h546YU+8GOzuZlIcwuP0ceN7kwWgizHBDkbBLXRP94c
	oEY+Mp0PDv44tZlsQ4DXQ9ozGJcTpu04hCfRE/rw3+kFDLl+mZ/vk6NzB9Jgzdr/DLA==
X-Received: by 2002:ac8:2d19:: with SMTP id n25mr49853119qta.180.1563804715034;
        Mon, 22 Jul 2019 07:11:55 -0700 (PDT)
X-Received: by 2002:ac8:2d19:: with SMTP id n25mr49853047qta.180.1563804714250;
        Mon, 22 Jul 2019 07:11:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563804714; cv=none;
        d=google.com; s=arc-20160816;
        b=RKYRvuQaq9Nq3s2a1PaBtXMD9VrAG9Xi6ePUrMf4ZXgVO4iOVFNZOui3aIKT2nN7v5
         Ssf9C4Q2nzNoaX7yCEcUqKPvAalHfpUobEW1DIItDbkpEuPDs46TD4jDFZjgdEpN2mce
         j0F0VRTcWrBkpfOpLdqPRioSq4pZiLSSJaRNuEe8uxkipErwDr6DXJa/Nr67AUkIGuVC
         GBrg8ECkYTjSVPnAMyBUiRJfPOUy1id3j60L0jU3HTasqnyXnoOiI7eJLE9ciDCG6Y91
         OFmegqUAocCWRvRLJ+tdm8buoyiAWxGEeogkVDL3S5NdoVWOuO/ihZ5w8j7VOtU8Kzfm
         DYfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LtBWSYY5RJyJ5bjGuD8GT1ULGrE6M+cxt5l8yU6kpN0=;
        b=a10KLrwZG1sr1xr+5tdM/cPwtav9JQ5DZQbIcqA2RL1cmgl0QSVYvzLnNlo7QLwIQv
         Cyxz3ZGIaRBnfkzfEeuyQKeAxvwVPweAHqInZajFG1tLNcbcCFATnWEpcWi8DIaz6140
         GiaSSZp0MfFy33b3nO2eqXxRmTitRANap48bxonPshGYbr+g/WrFsPOxiRb7LIgO+Cer
         8C8BGz/8KtkmiSYN1aGkxsd3TMAnQH0DxFRdb4Luej+d0BSvcz0gYKahN7MFpYdh9MKI
         LDaWfpB+FtBOldEmS8e6FC5xiXqzp+OlO1mYt3tcMf0jNpOkHhrlsfv1W5nR7issLzLE
         oiyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AqJLL2tA;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m17sor52630983qtp.16.2019.07.22.07.11.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 07:11:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AqJLL2tA;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LtBWSYY5RJyJ5bjGuD8GT1ULGrE6M+cxt5l8yU6kpN0=;
        b=AqJLL2tAQ8qmfza+BbBBA30hBmiEi4pm7Bd30lUGLJdSyVKKuDWuxFlP7RyECIj17b
         XJpeqNQH2wamruofikS+opbhHXR87C/2P4+HHr/txKjdnmmTrCfU3/FvIDauFeGsqdLX
         9N8TDemI/FqJTetBBb+eMeMhgwvnuJ3+QSjcM18BJqZFbPTYbz22jGuEVhjAl1NeRhMe
         gMsST/gm4oj7anPp1NAGwwTiAl7EGdHZhvi9wPgzVP0639DiVRWlp0mKEsh+gaWi/vPE
         9sF4SdwiKYxgei4G8H6O23RQvFqbuu976015rHkp6asEVORyBSYPRzufJqJdiSfpQaVD
         Edlw==
X-Google-Smtp-Source: APXvYqzJhWJh0JG/V+RW4LMQbSCenJcJXUz5oFlysoNrpAnk6aDKO1gmwVookMZq2D7vPB1tr+gYAg==
X-Received: by 2002:ac8:3794:: with SMTP id d20mr49622645qtc.392.1563804713889;
        Mon, 22 Jul 2019 07:11:53 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id x46sm25518922qtx.96.2019.07.22.07.11.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Jul 2019 07:11:53 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hpZ2e-0003yO-Ou; Mon, 22 Jul 2019 11:11:52 -0300
Date: Mon, 22 Jul 2019 11:11:52 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jasowang@redhat.com,
	jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190722141152.GA13711@ziepe.ca>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721044615-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 06:02:52AM -0400, Michael S. Tsirkin wrote:
> On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
> > syzbot has bisected this bug to:
> > 
> > commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
> > Author: Jason Wang <jasowang@redhat.com>
> > Date:   Fri May 24 08:12:18 2019 +0000
> > 
> >     vhost: access vq metadata through kernel virtual address
> > 
> > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
> > start commit:   6d21a41b Add linux-next specific files for 20190718
> > git tree:       linux-next
> > final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
> > console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
> > dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
> > 
> > Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
> > Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
> > address")
> > 
> > For information about bisection process see: https://goo.gl/tpsmEJ#bisection
> 
> 
> OK I poked at this for a bit, I see several things that
> we need to fix, though I'm not yet sure it's the reason for
> the failures:

This stuff looks quite similar to the hmm_mirror use model and other
places in the kernel. I'm still hoping we can share this code a bit more.

There is another bug, this sequence here:

vhost_vring_set_num_addr()
   mmu_notifier_unregister()
   [..]
   mmu_notifier_register()

Which I think is trying to create a lock to protect dev->vqs..

Has the problem that mmu_notifier_unregister() doesn't guarantee that
invalidate_start/end are fully paired.

So after any unregister the code has to clean up any resulting
unbalanced invalidate_count before it can call mmu_notifier_register
again. ie zero the invalidate_count.

It also seems really weird that vhost_map_prefetch() can fail, ie due
to __get_user_pages_fast needing to block, but that just silently
(permanently?) disables the optimization?? At least the usage here
would be better done with a seqcount lock and a normal blocking call
to get_user_pages_fast()...

Jason

