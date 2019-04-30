Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01079C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 16:28:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B369F21734
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 16:28:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="F7Xp6ft3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B369F21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D5686B0003; Tue, 30 Apr 2019 12:28:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 485896B0005; Tue, 30 Apr 2019 12:28:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 374786B0006; Tue, 30 Apr 2019 12:28:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F41B6B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 12:28:43 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id cp15so3430281plb.10
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:28:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DqXnB4Ieicg5n9zZ05HJmEnLSbQE77UGcjXBFZAcsZc=;
        b=oWsfMJb9ielPJkwZqX3DLISFMoHE6RsJZ9gwt8cJZbvjYvwOPpOXocsX7Acjr6R6+Z
         R4EhR1fDewQc2a57dQtFAd/kVkz0Ak7HWKwZ+2FPPxspsxfQJmXp9jqgbx+1xqq55pkQ
         CioCvckOV7xlF8ZFXogwOQDAuQkL2BMPcyoIERbohRnox3eoohobG5fDajY1z8xnIS4U
         ZUl481btcARtjImB8L+4IfIxVPIjVi36HTVljoEyvZfLvKkBbpjKeC6xlc1+DU7/Q6od
         MqVbVF7LTD61xmJBp7Jr4jJcqZdPmit6xVd62efAs/Q8PXPaHajsXkuWjUP82GVX1AOv
         YTUw==
X-Gm-Message-State: APjAAAVOJ4uXr0rLojaIDzsa7HRCYq03yiZMT0T9r97vnFeJKFw1cuSR
	UjvlDZvDZanks1/Auk25q8qGg8Ypbt94vXdbwZyksA/lBdZJcIVqJvvD8hlqBga3uxzkn6yPAVp
	ZJU/HHFSCTryIHhNXlxt2TaxvuhrDb0k2k28yf0d7sGfGKRTKtzA7DqLdzIXPKJyC5A==
X-Received: by 2002:a63:b507:: with SMTP id y7mr34848809pge.237.1556641722385;
        Tue, 30 Apr 2019 09:28:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXpiHfX/QvMtRBP8VJFPStPDtUK/Tn5fl3IabyUv8pvH9o/fSry1bYXPyuZGHDiUHnNNot
X-Received: by 2002:a63:b507:: with SMTP id y7mr34848749pge.237.1556641721734;
        Tue, 30 Apr 2019 09:28:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556641721; cv=none;
        d=google.com; s=arc-20160816;
        b=wrx/c/GPW+YnrqPuQct1I/Rf1S7sXJJ4l48nnnIezElidSyBLFvy++vMb6Al/AlV5Q
         HMvMACtgzkyrsBV3UA8UaY87fjr3hZreC/Ev99Qs9YEp80tBgf599tkkSlhxWKMJFGMK
         sfBN4nLbiI9lFky0g4a7nK1VA/xV0Nn9c0OV1N8JfuwhqQVy5b+n6Qs7ZWIzTbtaWm/I
         qpKjkJxuOOfG5sW+pkX14H6Tzvd09TN/3pJ4mGEJKsP4IZR7HcaBCH19QZdlomg1EV0f
         2KLhEbydonlqtkRJ21cTHl28iqWjxbtFkCNvO3jyEw1nlUYz6PfH/4jTp+piARb8Mv8I
         FuWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DqXnB4Ieicg5n9zZ05HJmEnLSbQE77UGcjXBFZAcsZc=;
        b=Q7LlByKplZh4st0ixKAcxLHx4M9l4Lg5VdN2gOqMdvSlR/CnoMFsh1xCEy2LnO0km5
         UhkuNPcG70jBJqZgIbdBKj2dLqNcdnubx79R9r3cTjs6PoapN+LXJsTjllAPLMj2Ev0h
         +Honw7i7Nad5DYAQ1mTdLXyKUhh1PpwzpfCYHNDDGXsrfdbtU0zg3cG9DQNtVdwWLyVm
         rCeaXZvhqJoKh47AMh2ozSWS51NbavR2zK1vhe2NEBWk/0Em3yJIqWl+283FnCVQvb5f
         dRXaIwU/bqPJ6JGHB73a37WenjkVXVzun/9PxM1LEBFxMie6BMF7LbAv6bSZfralx3Tp
         F2sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=F7Xp6ft3;
       spf=pass (google.com: domain of zwisler@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=zwisler@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 125si34963905pgc.220.2019.04.30.09.28.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 09:28:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=F7Xp6ft3;
       spf=pass (google.com: domain of zwisler@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=zwisler@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-vs1-f49.google.com (mail-vs1-f49.google.com [209.85.217.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4B6622173E
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 16:28:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556641721;
	bh=DqXnB4Ieicg5n9zZ05HJmEnLSbQE77UGcjXBFZAcsZc=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=F7Xp6ft3oOZSu4E6woaVktGPjIMe9N13aPvHmSQW/qIVySRoqYf973EUMMBvN0A6g
	 zmY47MRMtJIGNtf0pWjVGQKl8QPcmcc5PzUJxCvoPUO+pp86w37CmyKv/naRfcAuQY
	 BDShSN644khjbZCUkVl0/AN2UHc0rSUxpnAUS0wE=
Received: by mail-vs1-f49.google.com with SMTP id g187so8364837vsc.8
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:28:41 -0700 (PDT)
X-Received: by 2002:a67:af16:: with SMTP id v22mr1668807vsl.221.1556641720489;
 Tue, 30 Apr 2019 09:28:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190430152929.21813-1-willy@infradead.org>
In-Reply-To: <20190430152929.21813-1-willy@infradead.org>
From: Ross Zwisler <zwisler@kernel.org>
Date: Tue, 30 Apr 2019 10:28:29 -0600
X-Gmail-Original-Message-ID: <CAOxpaSVBxziXH+=5200wGeBDpciJEYcu3RKBftqNwcbemK8tjA@mail.gmail.com>
Message-ID: <CAOxpaSVBxziXH+=5200wGeBDpciJEYcu3RKBftqNwcbemK8tjA@mail.gmail.com>
Subject: Re: [PATCH] mm: Delete find_get_entries_tag
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 9:29 AM Matthew Wilcox <willy@infradead.org> wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
>
> I removed the only user of this and hadn't noticed it was now unused.
>
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Reviewed-by: Ross Zwisler <zwisler@google.com>

