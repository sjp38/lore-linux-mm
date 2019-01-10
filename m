Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47197C43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 20:44:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2D3920665
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 20:44:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="TAC164qN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2D3920665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92DE78E0002; Thu, 10 Jan 2019 15:44:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DE418E0001; Thu, 10 Jan 2019 15:44:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F5078E0002; Thu, 10 Jan 2019 15:44:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55D288E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:44:36 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q33so12642600qte.23
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 12:44:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:date
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=LiawR9Y4EId2HmnEiWWnQVQHGhE1inrk85t73A47gpM=;
        b=oRy6OXqMuErtfOb0tId7bU+UW1/Qa0WV8RVAZAN11ecgDOXBkxQhF+RtflZAG4kOw1
         nbExBQSnS1jNfou+TRwJqIimQVRebfKnv4WBZaO3GvUqRoOACAFEqRmgRj3HNJXC2iMU
         ZUc7ZQOH5hnAACAYe4dfoUqPkW2DINI72jMP95L6lBfEKseL0uj+9xTQ37dPJSGWfgm7
         XuE19XAaCK1GkofjzE5ZIJYS/hjubRYIrZTx7BCAAhQXDGu6j9y5TrNQPQSviVNwgjN4
         3rLAZ4hDEe9di6CpZbAtsKuCW/J7NYzgdHj5EWEEXSbNBNWNgP3XZRy+K2GVlMbNr4Fc
         3mlQ==
X-Gm-Message-State: AJcUukeSP5pzbHknNmwSzfJWVcvQzzK1ZLYSaqDzQo8ZWldjEG6gLDyP
	uNtecmoJuPF+IRDzPhLsuE3CBLt9fHFX3MZ877W3taNMGnO7OG9mS5xxN8uPHdQ2R9jIXJprlcD
	AxloCAY9zDi3LBjRk+4FEybwdSgvc4PVkQdqMB9cd0XKd+OwgtWIgucL+EdUZ8Ht3PrODsLTSTy
	AGYEbHBInFr66+SsoMWWX3/coP74ijiBhJFd6eiwoPYYi9yiv1Z1u4ZGH594XWRKiPvu/txsxWa
	RrB22tw4iNWpkH4wThVLxAwI7QBm6SosOHgi+vkHLH8UrqFquxXDmdzD9hT2OJpm7kz5phBwQjq
	VZd9sgqmVysGXBNVW7h868VqyFB6Rzpxd9GnkHuENE/LIQrL/jWG7OHgCC+7P+mm2YDDSZ/eL2o
	4
X-Received: by 2002:a0c:a3e2:: with SMTP id v89mr11421865qvv.226.1547153076098;
        Thu, 10 Jan 2019 12:44:36 -0800 (PST)
X-Received: by 2002:a0c:a3e2:: with SMTP id v89mr11421836qvv.226.1547153075621;
        Thu, 10 Jan 2019 12:44:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547153075; cv=none;
        d=google.com; s=arc-20160816;
        b=E6cu84IdYtclCn7QwEmsB+iNTFH9pQcvQsMrbu1nT7foTsF77W5GOE5jjcdJFFccJT
         xRoZNIF7qyXzT05gxzTuW1wdEafGeQk7sgib9LSKuAJTlQtRZ34zfxqmxpD+2U3H6GA9
         tZBXx6s7oSy8Xy/w0ayw+DhBDZsG7pIxcEiDMk59jdXcYAHl4DsfsQtzk9at9VOQiF2e
         RBJBxs79deGmTwEcM9jJkC0l3BDtVS7I5Xmxy2HGuHH0NRaB8fQGNjETugEH1SClu6nT
         eRwCvRiA9DV3xP+lCdEq/x12bz7/WYZRdigk9Jdmv79XQ43igT2OUSTVzC7Z/nTGUCXv
         HP2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :to:from:subject:message-id:dkim-signature;
        bh=LiawR9Y4EId2HmnEiWWnQVQHGhE1inrk85t73A47gpM=;
        b=aedmHSCs+vxMixIc4SqvH/aHeSNrE0KaeSmu+RTefCAgdDVU0gQbCk+UIAyk+nJq7f
         FSbdAI8xnk+RglIuZMNjVpcjEZ9zDc9Epz/4+kBNPCXAejSSq2wWNU7Fp3yNnExh+vBr
         xadKPVBvvIXOm7xcnJbnYq73gxkrUBJWFQUuhpOpYsqPvARi0budY6ua0JiMbsMjr4DY
         9EGCjsWZReXHIfpu1fCiFppseS8+jqYbQ/iPWrdz7tei7usgmypkE16Qp/v3gcIgWjJx
         09X8PUFiF4GhARLd3tVKpV+r0L/ZPc0uC3P4j3EiC707L6Np3zv7R2HXWOEWWSAvipdZ
         reKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=TAC164qN;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b127sor36586224qkc.48.2019.01.10.12.44.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 12:44:35 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=TAC164qN;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LiawR9Y4EId2HmnEiWWnQVQHGhE1inrk85t73A47gpM=;
        b=TAC164qNxX6pCF470izPjspwoGJ8My6MxL3m/OGJcygmVV/w3PXD33j8Lz3o9N7c3Y
         YivpqTsPh3x/uNt83i5CdFVZBFhNVGCpqlQS91hDS/2owIoEoijbgTg1Ssw/xEb3+0l6
         GvPMle0s+pQvvgO1rnE473g9TNjJ3o5QkDkVTNcMlavW1BPuqEqwPtGRKl2v7Y3QZdVS
         rUOWSb7XhPNWGSVs+E7DQp4BRGD3KfXZZMpZPfgNkufVQbWd1UZKvkDKAiZbHmyE5e99
         C2xyoMSUIK1zFbaX0bYCbsA0WPhJXkyOpOlenpoXoxgeBpEfknRHe60avw65pSwQaFZd
         CHLg==
X-Google-Smtp-Source: ALg8bN4qv1tInlK0ItvrOiYSkskO+hotyjP0WRNtOALskW1LMjNt/TePuBtZNe7vwbmBHG1CfmrB2w==
X-Received: by 2002:a37:8c04:: with SMTP id o4mr10270933qkd.165.1547153075405;
        Thu, 10 Jan 2019 12:44:35 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id y14sm47282899qky.83.2019.01.10.12.44.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 12:44:35 -0800 (PST)
Message-ID: <1547153074.6911.8.camel@lca.pw>
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in
 user-area or NULL
From: Qian Cai <cai@lca.pw>
To: James Bottomley <jejb@linux.ibm.com>, Esme <esploit@protonmail.ch>, 
	"dgilbert@interlog.com"
	 <dgilbert@interlog.com>, "martin.petersen@oracle.com"
	 <martin.petersen@oracle.com>, "linux-scsi@vger.kernel.org"
	 <linux-scsi@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Date: Thu, 10 Jan 2019 15:44:34 -0500
In-Reply-To: <1547150339.2814.9.camel@linux.ibm.com>
References: 
	<t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
	 <1547150339.2814.9.camel@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110204434.fPYNvE2VgpFrR6ZGAecC1GKH_1mGs7BSksRjCa4P7iQ@z>

On Thu, 2019-01-10 at 11:58 -0800, James Bottomley wrote:
> On Thu, 2019-01-10 at 19:12 +0000, Esme wrote:
> > Sorry for the resend some mail servers rejected the mime type.
> > 
> > Hi, I've been getting more into Kernel stuff lately and forged ahead
> > with some syzkaller bug finding.  I played with reducing it further
> > as you can see from the attached c code but am moving on and hope to
> > get better about this process moving forward as I'm still building
> > out my test systems/debugging tools.
> > 
> > Attached is the report and C repro that still triggers on a fresh git
> > pull as of a few minutes ago, if you need anything else please let me
> > know.
> > Esme
> > 
> > Linux syzkaller 5.0.0-rc1+ #5 SMP Tue Jan 8 20:39:33 EST 2019 x86_64
> > GNU/Linux
> 
> I'm not sure I'm reading this right, but it seems that a simple
> allocation inside block/scsi_ioctl.h
> 
> 	buffer = kzalloc(bytes, q->bounce_gfp | GFP_USER| __GFP_NOWARN);
> 
> (where bytes is < 4k) caused a slub padding check failure on free. 
> From the internal details, the freeing entity seems to be KASAN as part
> of its quarantine reduction (albeit triggered by this kzalloc).  I'm
> not remotely familiar with what KASAN is doing, but it seems the memory
> corruption problem is somewhere within the KASAN tracking?
> 
> I added linux-mm in case they can confirm this diagnosis or give me a
> pointer to what might be wrong in scsi.
> 

Well, need your .config and /proc/cmdline then.

