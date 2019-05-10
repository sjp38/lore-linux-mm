Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 982DCC04AB3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:50:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DFAD216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:50:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UGioXCqe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DFAD216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3DF06B0003; Fri, 10 May 2019 12:50:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC5FD6B0005; Fri, 10 May 2019 12:50:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B67C56B0006; Fri, 10 May 2019 12:50:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF726B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 12:50:05 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 61so2929065plr.21
        for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2wDha3EADDmfVVXYa7ajyQwnvxNiFO3eCGthoVo2HcE=;
        b=WkIH3DuVB6wXLGG5ExcJvmy6wvuL8+GPngEEEfjDWV/9GppmAGra+GXV7T7zM02Rq/
         xexQaOExKtnG2MmykYntdSrkJoz5ZXIC6fzIAEH1zYpxiGVX0Veh9QT0PxMRbLsp1ixQ
         ItnS1uxcjbUNyx86Nlo5wRc5+g0iaq8zpB/gLVkAY1iLpXQqJO1rnmCSXJiLMOzgaCDh
         9joy+V/9U7KswmDX+sIWI8bUnwzHNGlrRedCZKaKUfvAKs3vcY8Z4/xFEaO4qMpfERKf
         JfzUmnmnLZbRiZNjpMCrI5nd0D8nRqLY6rJXyTcP6H0HKjJMSo8oNI74n5vWCpv4LROb
         dvOA==
X-Gm-Message-State: APjAAAUynBR8DTp+oA+6Dk9JORzqIQU3yItIszvk/d8IV4UgsP4qy862
	2V4+MDytG0SSs9Gfc1zGYJgaWTklr4qkaEYAU5BnjgdzhyVebEct0bB7vOur367P4tztU/fMC79
	04Tn3AhZGS1P3nEjzXoj+i44y5JyisKsZToPD653zqskO+NL2HHwdWQW9ItDMqCU9Bw==
X-Received: by 2002:a63:fd0c:: with SMTP id d12mr15162029pgh.391.1557507004989;
        Fri, 10 May 2019 09:50:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIKwnw9OUin+JUmOBcljJxKxhZCcCCdQ3HptkHtjK6BeiIrNYMcTw/u/umIAyASGhh2KXl
X-Received: by 2002:a63:fd0c:: with SMTP id d12mr15161940pgh.391.1557507004311;
        Fri, 10 May 2019 09:50:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557507004; cv=none;
        d=google.com; s=arc-20160816;
        b=KZROCLdM3tVngcqtZzx8+7sG5iXCK10WuP/W46Nh75Ao5kJ2//tkjhYBwnBbMX5OMr
         VSnUWV48UTQh6+HyDGBSxbDOMGu4O1IPvFlGZzN3ukaEwk+UNkA6q6mSZiMnsYs3FoS8
         XIAMV29Qsxoo2mwa4ZMuPMjFtZZA5MULogWIxDZeaNBss3/4vif/767whQ0SuyDKp7dB
         3FBHypM27xbWqL6iBPxfjjLDO4uMhlGVTwiy4QDgHpfTdiWNu9ZmJ7Ut5TT+a+MT5728
         0Co8iayb8t8AJKCHUSSTdsUGaWXePwKSqYRpwGT0bhbObKEG7+TwulKh2PhHC6CZXRXx
         w9Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2wDha3EADDmfVVXYa7ajyQwnvxNiFO3eCGthoVo2HcE=;
        b=FEk/ExNXwN8PZgGyoh2dNpUWSzXbKVfk+DOjURMVY84amchzovRTnsK824API/T1gB
         Yyl7IM/NS490c+/NJA54KVpRGus8132Yxa+qgaR5kSVu041g5nAT3eBxSUEaqY6oye0G
         s7OI/DTkghIH//EfJ2gWT7PaX+zP9wtjGrmrPir8I48GgZt0viiwvyDpAw7p7Ef/0v8J
         oQ2QQm2mWEu++9SDy7cnV4N7kyywR2FEn3FEEXhfU9GP4mnsdq4CvgbuDyhOfV3cwstH
         RV4EiDxcniYkepIYbxsj1pugeMru77q24rnTD+na2ILmSV51NM+EDPsaGgto924bxCDV
         YGXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UGioXCqe;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id be1si7463969plb.286.2019.05.10.09.50.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 09:50:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UGioXCqe;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=2wDha3EADDmfVVXYa7ajyQwnvxNiFO3eCGthoVo2HcE=; b=UGioXCqe3H/j7ccAJjmTgLBqO
	72UvtDgZeAj/jFqp4VpkW9Vr7OyPP1mvXcReCFw3chW94BqjfVGRSISrEf227FsP9j7KE0VBeEqAR
	zDnyJu3Goxi6fDhV2dJEK07uLVIYhodw0Wj38lFQ7nmV7InGEAp0PrV2vFyGWPUA9UnhVrWhvwbPf
	pFe84JmmyvnWGlnV5RnDfHUPmS4mSMKKFy29Ey8lToAmj7Tq/SX4//oUP8u0XkeBdF0pSZiKNh3H5
	wes9g+5ltMNz4fgTpBnkBYrdhO/vyXzE0E79B/biBqu9KcOjpp3Md+7122dpPeCVI2oPEUDXe0sYM
	FAjaQBxzw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP8ig-0002nS-4o; Fri, 10 May 2019 16:50:02 +0000
Date: Fri, 10 May 2019 09:50:01 -0700
From: Matthew Wilcox <willy@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: Bulk kmalloc
Message-ID: <20190510165001.GA3162@bombadil.infradead.org>
References: <20190510135031.1e8908fd@carbon>
 <14647.1557415738@warthog.procyon.org.uk>
 <3261.1557505403@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3261.1557505403@warthog.procyon.org.uk>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 05:23:23PM +0100, David Howells wrote:
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > What is you use case?
> 
> afs_do_lookup() allocates an array of file status records and an array of
> callback records:
> 
> 	/* Need space for examining all the selected files */
> 	inode = ERR_PTR(-ENOMEM);
> 	cookie->statuses = kcalloc(cookie->nr_fids, sizeof(struct afs_file_status),
> 				   GFP_KERNEL);
> 	if (!cookie->statuses)
> 		goto out;
> 
> 	cookie->callbacks = kcalloc(cookie->nr_fids, sizeof(struct afs_callback),
> 				    GFP_KERNEL);
> 	if (!cookie->callbacks)
> 		goto out_s;
> 
> These, however, may go to order-1 allocations or higher if nr_fids > 39, say,
> and it may be as many as 50 for AFS3 or 1024 for YFS.

kvmalloc() is the normal solution here.  Usual reasons for not being
able to do that would be that you do DMA to the memory or that you need
to be able to free each of these objects individually.

> Also, I'd like to combine the afs_file_status record with the afs_callback
> record inside another struct so that I can pass these around in more places
> and fix the locking over applying them to the relevant inodes.
> 
> So what I want to do is to allocate an array of pointers to {status,callback}
> records and then bulk allocate those records.  As it happens, the tuple is
> just shy of 128 bytes, so they should fit into that slab very nicely.
> 
> Note also that the records are transient - they're freed at the end of the
> operation.

sounds like you free them all together?

