Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 320A2C282DF
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 20:11:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC136217F9
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 20:11:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC136217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 914AF6B0008; Fri, 19 Apr 2019 16:11:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C5916B000A; Fri, 19 Apr 2019 16:11:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B4406B000C; Fri, 19 Apr 2019 16:11:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 463056B0008
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 16:11:22 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t17so4023268plj.18
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 13:11:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RimhnJlnoRmpjtwXEyiPTqpFlyJ+bS04pLEY2V3dsHY=;
        b=tqoTRVMAnyKBbhuHh1arDVbnpb/zo0W1HWiC37jz5dzJQ5mnfKTT3SrXcrXJxhstnJ
         OzsfMqgXb/oKzPDuzhUPuuz8Pq8tnmLSPCHmrn60qxV6duZVHX9P96vYDqpy5VOKzN7o
         o0Q0zCQAtfP5LyQKaUANSGyB2IkiEsI3FlEstun33/r1Vu4bwBOnlv1zYk1aTOv7/vFU
         eYFX6b17TcfPAoGQ+lijV8kgqJsJsamc244SchGWh8EEKN2EiOM1lGmlnWDFUlHwOZmE
         qZtt4cMwmCpCgPoPDrDyCcHdSis+qEvozkA5HtYo0T/iK0Imj14incFal8NJXhqm3A1k
         DDWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAUeQrXOvo1PzSquilJrcaX/W5q4PYbsMHeRHWxUkVlnfuz2DZv6
	BvHIzDIzXYy2uqRSS29Pwgx8ka9It6b2YZI718Zm6539/mn8Cz2HvVQQ2VGZ0yQbQQJhWMDcvGG
	cuGPAC8fA3aIT2oahVZ+0zAr3O8BJBSlLIbSTjDbsuNXngrWpJWaZAatsFzPUdj0=
X-Received: by 2002:a17:902:2a6a:: with SMTP id i97mr5880383plb.332.1555704681941;
        Fri, 19 Apr 2019 13:11:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6T4TAWGWoX1hBQ2Zgdok78apmbewjKAz/PdobzY/+78mZ+lG4w5CNNEEhf4X7kbH8ngST
X-Received: by 2002:a17:902:2a6a:: with SMTP id i97mr5880343plb.332.1555704681378;
        Fri, 19 Apr 2019 13:11:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555704681; cv=none;
        d=google.com; s=arc-20160816;
        b=lbZdQnpX8yBMa+EOSalD+jX8iNpJGtVWajyjs9hfxH9kq1pHqdymW+2KNH+tmxVDKl
         lX0E7eV5iVuFvbPZCSvs5sLczsQHNAH/dtjqG5Gpcour/q9KJSvHSISYj2zDXXLIVsib
         +1/EJJC3rQq0QrSgfrKlP5iIfeJUPlTIfBNyYLhygeeQpi+e4xVZmvG0pD0KUfis0SSm
         HI499gugjFM2EMljo8fnI3GTMR5x2+4iKDFvjoUIPRbN1U35/lPchNbX2/yrrXg/JC+1
         u9ntaGR+9+Gl9kGPrZiXIAbDq3ANImpRxPUsjlWoFqhz3YJU5358G5nA+1GPFxB/ZgqH
         OzLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=RimhnJlnoRmpjtwXEyiPTqpFlyJ+bS04pLEY2V3dsHY=;
        b=Y4JIROXJOMhIEWs5VSCN+4tDdGV/jQ5SEMBYBYhtccQ/MAVMJwvsAdwL3hwgh1GjWm
         7lxLVzl/Tbi1KgFNAoFYcg0681nH9ooTGI6Ty586gMJXdPhZHQwf8uH+Yiyd0HTu8iRD
         8QTsMt+stXgJwYdj76dPAriIrV/zfstFXp+FHPNadx6IX7/TWSSlNFoR1swvnMdHlXku
         FEHxLipmG2mq0I3U0GdZGzvKUkVT+sQrdpbvpDY90juyV+M5EAW+SnRVSAf4/Mx3r173
         woO3ToqwyOmJP/48RcQYCovusWbGnsRqT6Khh0Ly8AkSahoeDWSFuZKyK8TrnZm3YEp0
         wscA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y3si5881397plt.57.2019.04.19.13.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 13:11:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E1C6321872;
	Fri, 19 Apr 2019 20:11:17 +0000 (UTC)
Date: Fri, 19 Apr 2019 16:11:16 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf
 <jpoimboe@redhat.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>,
 Alexander Potapenko <glider@google.com>, Alexey Dobriyan
 <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka
 Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes
 <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Johannes Thumshirn <jthumshirn@suse.de>, David
 Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, Josef Bacik
 <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 linux-arch@vger.kernel.org
Subject: Re: [patch V2 24/29] tracing: Remove the last struct stack_trace
 usage
Message-ID: <20190419161116.14f52ff8@gandalf.local.home>
In-Reply-To: <20190418084255.275696472@linutronix.de>
References: <20190418084119.056416939@linutronix.de>
	<20190418084255.275696472@linutronix.de>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 10:41:43 +0200
Thomas Gleixner <tglx@linutronix.de> wrote:

> Simplify the stack retrieval code by using the storage array based
> interface.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>


Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve

