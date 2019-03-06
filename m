Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20865C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:38:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9FB020675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:38:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9FB020675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AA6C8E0003; Wed,  6 Mar 2019 18:38:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 758308E0002; Wed,  6 Mar 2019 18:38:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 670428E0003; Wed,  6 Mar 2019 18:38:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 248768E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 18:38:23 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q21so15360053pfi.17
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 15:38:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B4ka4u+vO01I/LZgSFdmuXSOxsohv2gOAk9/gm3uaMQ=;
        b=KHBWWtJiX/3hjNImxbAZUPmtxmWxieV9lMpFoC7nc4ejYRAf414leb6L6wrxREq+Hw
         9CulbfeZ9QXns8h8I5Z04gBOVpGLr7sH++WBoX/kigSLPoxvOIRQaSBccslsJUrYkp/4
         WdD2AQ0HahSvi7uxhrEt82479UrFrJTSufBQsImOTngd1eOwCtKLPYPW5zObsLzDLxZl
         K0zkJVGlnPuL9zusnh6RI2zE6yPCDTQNZFsoByXodq020Z/pxKDA1dweZZqw2Wfks5BC
         4hC2JXtd5cKIDnfv9TB0Ivwly4ULit9i5nyuC/ZhehpchyZK9pGfxhSTOumvub7TaGIU
         Dkjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVnQh1slHc73i7gtIP177sviV/1DpYT5wi7yXi2k4WTznJ+RoR3
	x6yiTYdafYkQdX0RACKjqUACpPXhpNIIgJGBCCxqQMmBnq7zZdUsa9iYZZ1yMDuc/z5IeVzxxgv
	tRIlVxHnPMt6EvhW2/w0lSXsAmH7aNVWstzv0jJhu91r3ieCeZGCKi5jWJiwVAOh1pg==
X-Received: by 2002:a62:204f:: with SMTP id g76mr10123231pfg.100.1551915502829;
        Wed, 06 Mar 2019 15:38:22 -0800 (PST)
X-Google-Smtp-Source: APXvYqypPTUvQvYRGmq6s2roS1SVAh+XarFeVfYMP6US+SUAeObPeHG7eq+HYTig3ernLtKTP6Kp
X-Received: by 2002:a62:204f:: with SMTP id g76mr10123180pfg.100.1551915501982;
        Wed, 06 Mar 2019 15:38:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551915501; cv=none;
        d=google.com; s=arc-20160816;
        b=SnOPSIc9bL56SqcmL0qCkO6OQHeM6XgnrjY4PJ93rD82K9HNVIJOtYnW+33JRu0zMj
         Pez/2w3rJPGNAqxm/7y/xVJzQNLrytwiowz/qj70ijY4xZRywzUX6YcDFpXJRTmhZvga
         m3kMYo7vgME2ZoN/jYyj145EskCcC2h718fw6qnpAV7eneZjUxk8gTa/Up7372+BK9e+
         eSpalk7oHiDuZf3N0/5IrprSa8ZUxyCGbt+m34h/3StX9INdn6r5CgZiMOiE+crTys/b
         iF8kxIAm87UI4HZpEGfpsDFc+CTLaSQRmMIBo+JnTK+f410pvS4vg7JVJnr71SeVrWz3
         LuBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=B4ka4u+vO01I/LZgSFdmuXSOxsohv2gOAk9/gm3uaMQ=;
        b=U31pIU3g9+FLPdckYx5uOxDSYXV+xpO2b1IMLl0KOyyMLs4Dwcija4A/EG/9+VD+bl
         isf02uBxX695MQ1pxGq38IEgqB8IIO2za4Ba7V3QWDfItwKq4WfJdqC/qPenwRj4Ah0d
         C9O7SdYFRCbKKGbnO6uo7+xUbq8JEeXR46ma1ocjftT7vxgX8b1/Jsuh9VJd8xnqstmt
         g6/GiQ+8oQpgs/yHvl0gIcdaSIcN0khfv0bn89MfheTVu85+lt9ik4eo1MitmjMuQ8yr
         +Goy/dgJpNO1deAiA30o7w9uVf6yWFbMYNJcL7Kjeddmq/1+C20F+VZzGBh2Pl9xGuPz
         ZB2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h6si2758283pfd.115.2019.03.06.15.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 15:38:21 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id DBE955AB3;
	Wed,  6 Mar 2019 23:38:20 +0000 (UTC)
Date: Wed, 6 Mar 2019 15:38:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Jiri Kosina <jikos@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linus
 Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-api@vger.kernel.org, Peter Zijlstra
 <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>, Jann Horn
 <jannh@google.com>, Andy Lutomirski <luto@amacapital.net>, Cyril Hrubis
 <chrubis@suse.cz>, Daniel Gruss <daniel@gruss.cc>, Dave Chinner
 <david@fromorbit.com>, Kevin Easton <kevin@guarana.org>,
 "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox
 <willy@infradead.org>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/3] mincore() and IOCB_NOWAIT adjustments
Message-Id: <20190306153819.3510a19ffe510b674a7890ce@linux-foundation.org>
In-Reply-To: <20190306233209.GA7753@nautica>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
	<20190130124420.1834-1-vbabka@suse.cz>
	<nycvar.YFH.7.76.1903061310170.19912@cbobk.fhfr.pm>
	<20190306143547.c686225447822beaf3b6e139@linux-foundation.org>
	<nycvar.YFH.7.76.1903062342020.19912@cbobk.fhfr.pm>
	<20190306152337.e06cbc530fbfbcfcfe0dc37c@linux-foundation.org>
	<20190306233209.GA7753@nautica>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Mar 2019 00:32:09 +0100 Dominique Martinet <asmadeus@codewreck.org> wrote:

> Andrew Morton wrote on Wed, Mar 06, 2019:
> > On Wed, 6 Mar 2019 23:48:03 +0100 (CET) Jiri Kosina <jikos@kernel.org> wrote:
> > 
> > > 3/3 is actually waiting for your decision, see
> > > 
> > > 	https://lore.kernel.org/lkml/20190212063643.GL15609@dhcp22.suse.cz/
> > 
> > I pity anyone who tried to understand this code by reading this code. 
> > Can we please get some careful commentary in there explaining what is
> > going on, and why things are thus?
> > 
> > I guess the [3/3] change makes sense, although it's unclear whether
> > anyone really needs it?  5.0 was released with 574823bfab8 ("Change
> > mincore() to count "mapped" pages rather than "cached" pages") so we'll
> > have a release cycle to somewhat determine how much impact 574823bfab8
> > has on users.  How about I queue up [3/3] and we reevaluate its
> > desirability in a couple of months?
> 
> FWIW,
> 
> 574823bfab8 has been reverted in 30bac164aca750, included in 5.0-rc4, so
> the controversial change has only been there from 5.0-rc1 to 5.0-rc3

Ah, OK, thanks, I misread.

Linus, do you have thoughts on
http://lkml.kernel.org/r/20190130124420.1834-4-vbabka@suse.cz ?

