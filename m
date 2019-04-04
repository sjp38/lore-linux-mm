Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 019FAC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 17:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A903D206DF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 17:21:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YJNHxbec"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A903D206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2886F6B0010; Thu,  4 Apr 2019 13:21:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20F926B026A; Thu,  4 Apr 2019 13:21:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FE446B026B; Thu,  4 Apr 2019 13:21:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA596B0010
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 13:21:33 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id g26so814596ljd.20
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 10:21:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EWEKv1NMWIXiFhq23uo1NeSiJc8e43y5G2cJ0bGNTbM=;
        b=irTbMfVqQX+/vwco+XCa3/hInt3kuqlKOx7HZUkQW5gr+idaXd5Nhhutw7Yjo3oJxQ
         2D/5d+/B0+OW74tFvtmmqGcIUpxvJDG0wwEUK9RDFBzsHS6NoXg04885hk1heA3DdAGc
         pmHhJc5j0MhVkuUopVQUf/s9xyedtg4gHpoxx3741Tyfma7IxhTrWKG27bsU6G1TuHJ1
         zLVQ4Bu9GxSyu78US1K3XN0ZxZecY/wBSapSKEW/R/YUBuBf83A4vZGZDsnqI4gK/OhI
         vsUc/0v70Deu1kCb2TkySpbS3oSGxpN18yIJAUSZYOBK59ni30CydeNgDxYWOjwKU0xT
         GgrA==
X-Gm-Message-State: APjAAAXIp/i5xwimVWuytnPFAgxhmg6J07a9Zp2HVXiYEbdubw/gyWby
	FyU6smAIuOeLE0FmhVTqFgPzZfCzXdYsi5JLXiULVWTSBO7rg2hnF2fP45eAQWedGpd3GwUPgfS
	X8lWRiMmDgyAv24FTbZ7Lrd5xhJo3g0RUe6Yalz115xR0OoGOTB7Jvy+VyY1goYxh0w==
X-Received: by 2002:a2e:9915:: with SMTP id v21mr4184291lji.154.1554398492759;
        Thu, 04 Apr 2019 10:21:32 -0700 (PDT)
X-Received: by 2002:a2e:9915:: with SMTP id v21mr4184253lji.154.1554398491790;
        Thu, 04 Apr 2019 10:21:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554398491; cv=none;
        d=google.com; s=arc-20160816;
        b=XSJu4M78e2CeDcHq3NHfbggqWiKU8GQrZfnt9AL5uDCsG/C1uJbnjGSAQqVG2FkuGN
         Cj2lvnOGEoPGt9vWOEEQBq5D19Owz2gz9KTE2QzSjM0///fG9721zgM5CGYNIex6/ysQ
         UBpbgKOvrorFXdRaR39MKv96cRWF40ZeRQClSt4Y/XBdcZIPaxG29jzmB3QDwCunITiZ
         d4l1s3s4wJek3i/g1qSfXXwbmNxF/+KT89ycySNtV28fahbDS1y148TWTLNIHh5MWcxv
         nvLfoZWW/LYcY3o0UIIKu5rh8A1r3pcPmapPZEoHaHwgxbc2wxL9u0s0LpROy0PBOr3i
         7rlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=EWEKv1NMWIXiFhq23uo1NeSiJc8e43y5G2cJ0bGNTbM=;
        b=RW0zGVIctPOJ6vqw5zuXxHTIJoC6rV3ZUU9WZPaLQ1MarSASiD9C8Q50WhHlrNJJTQ
         azZUDWbDnZ+MAP/pBTVc/AfHpAvdHmS5UOiiEYdB860SxM1w7NnJO3iZg5cSKz1uZ70d
         6kBtnxZZS4gpJRVSscqTGB32fAMZT5cay9Z3uHIHQxG4+8txe3+09xBvl4qRoUMkYHP5
         gcePhZoCmeqMT/5gOfIS/Dp1mxWvFemzkkcmJKgaRIbnGgIy9TQUnZsygaxeScLOEEwM
         xjyu2fVMJcQJl5LNBzpU4QMGvoChSbcTVF0xy0KO5IUkzCuj5CQQYS+O2kUWRR7MJRkR
         sc7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YJNHxbec;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h10sor5151871lfm.12.2019.04.04.10.21.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 10:21:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YJNHxbec;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=EWEKv1NMWIXiFhq23uo1NeSiJc8e43y5G2cJ0bGNTbM=;
        b=YJNHxbecPF0ms7B3c9l4EGrQH6ECiqr7q+za9T2PW9134zoLGG+Qu/0lL0jHFki7G1
         QXCFAM6TweMWpI539dPuiuXxZvQcrs7NLoKmgJ9zk/ThbHVKwAFeQOvEouCXpyUWtigg
         JeP4RtQiusUun5r+eTVAV6RkMZfc21fvCyJgwU//wYJXKo4U5Ag+reV6as2o/t1AoOgo
         RFYZPcXFfwGKimNwmfyDcnNGazgrE//p2k6YNsaOFcI5TMC+oEqXEiCRTqSKHqO4beR8
         WE1jcYV9yS67pwWb/hRRxrdBGTiTDkmpPffeXLP6A9GnOoJIEFOrfcojo+F4QpiN7yS6
         TswQ==
X-Google-Smtp-Source: APXvYqwX2OOtfhHY2DL3v1nRqPQ/q7eIwBHPwp188mKsSpo5w7gnU21d7a4viryln88M9dXopIc/mw==
X-Received: by 2002:a19:ca02:: with SMTP id a2mr4063942lfg.88.1554398491330;
        Thu, 04 Apr 2019 10:21:31 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id y10sm3742431lfg.44.2019.04.04.10.21.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 10:21:30 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Thu, 4 Apr 2019 19:21:22 +0200
To: Roman Gushchin <guro@fb.com>
Cc: Uladzislau Rezki <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [RESEND PATCH 1/3] mm/vmap: keep track of free blocks for vmap
 allocation
Message-ID: <20190404172122.2u5g4eppkn7zcunh@pc636>
References: <20190402162531.10888-1-urezki@gmail.com>
 <20190402162531.10888-2-urezki@gmail.com>
 <20190403210644.GH6778@tower.DHCP.thefacebook.com>
 <20190404154320.pf3lkwm5zcblvsfv@pc636>
 <20190404165240.GA9713@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190404165240.GA9713@tower.DHCP.thefacebook.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > > 
> > > Do we need this change?
> > >
> > This patch does not tend to refactor the code. I have removed extra empty
> > lines because i touched the code around. I can either keep that change or
> > remove it. What is your opinion?
> 
> Usually it's better to separate cosmetic changes from functional, if you're
> not touching directly these lines. Not a big deal, of course.
> 
OK. I will keep it as it used to be. When it is a time for refactoring we can 
fix that.

> > > 
> > > The function looks much cleaner now, thank you!
> > > 
> > > But if I understand it correctly, it returns a node (via parent)
> > > and a pointer to one of two links, so that the returned value
> > > is always == parent + some constant offset.
> > > If so, I wonder if it's cleaner to return a parent node
> > > (as rb_node*) and a bool value which will indicate if the left
> > > or the right link should be used.
> > > 
> > > Not a strong opinion, just an idea.
> > > 
> > I see your point. Yes, that is possible to return "bool" value that
> > indicates left or right path. After that we can detect the direction.
> > 
> > From the other hand, we end up and access the correct link anyway during
> > the traversal the tree. In case of "bool" way, we will need to add on top
> > some extra logic that checks where to attach to.
> 
> Sure, makes sense. I'd add some comments here then.
> 
Will put some explanation and description.

Thank you!

--
Vlad Rezki

