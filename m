Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D700C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 21:06:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 404342070D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 21:06:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 404342070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F4838E000B; Wed, 13 Mar 2019 17:06:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A2338E0001; Wed, 13 Mar 2019 17:06:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 893328E000B; Wed, 13 Mar 2019 17:06:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 438BF8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 17:06:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t4so1325079eds.1
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:06:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3VovhBSTW3HniGg4Z2OKgLJaVgk+mldhh4mTxqeNiiA=;
        b=KJVtSn6KRolPSHzhRgh1WpWt1l/xllm9YibQroB0yHd/eR4LXGnhTpG83MbSl7nbCv
         nBY1K8JZDbbJ0OIzZ7pFK635kN18dC6yog8mTgrTC0iK9u56Tn2+Ii8oDeEd+NX/n7TK
         xYobdBPQH5FKMP0YGuqeqskUpLZHulG5ZlL0RyMXE+FeSNnhEIkeNSUPBBIGC9bDKop2
         TwhubTaCbCVixpmGeZQnrQtkywhx+vXphjHYkyM9XlGPiD+cCcXzX9jCeEZEFrdL5f+8
         sIcIwZAEz6spLADw56gcCjFcGz8DQM/30+5bXJHskfXxQYL/1ZZw2Z6+PnvIJA3a7tMo
         URHQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAX7ler526Wy6A54P6DaEcoLxtDxa6QP65bxIEF5kY2qrBMdcaxD
	nWaxlP2qsXES/MZAWuv2/umlXOZCPSv9uSQ5kR6UHXz8Iz+FALdw/BzKuVB6NsBi26zm5Gamzxa
	q9PnaCNdusGgO93Yt2bneCVq68zPm8Jw6ejhiD2O2VvRMImf8rNgA3+p58NoK6Ag=
X-Received: by 2002:a17:906:32ca:: with SMTP id k10mr11852156ejk.115.1552511171757;
        Wed, 13 Mar 2019 14:06:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHpbFymB37sYEn9Irl1QZJ/lwe6oKT8iCgRYOcrXmZMEGIVs0agkAcQNDFh9klzhtg4lU6
X-Received: by 2002:a17:906:32ca:: with SMTP id k10mr11852127ejk.115.1552511170778;
        Wed, 13 Mar 2019 14:06:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552511170; cv=none;
        d=google.com; s=arc-20160816;
        b=bqeSPp28mNizeI336okxX+gkpjLCogFtW3s6J8cpRYqTeelNCYc9hc4y7hRJSwhMAO
         FNefKr4DWzn6Mgqz8GgR96zBzNbhIFf4ZQ3+5zrOgjO/2r9Ixlp2YmOCisAtcbohZZ3K
         aX+I44ya6cZ4pwuG5DAp843aRE1Fd9yvLC5rr8J5I9Sf1YCMKAFNjMnPU6Y+KaJxnIDs
         n+spd55pys45MqOHXgRsMNhrDNyogncaxV9q/CYTbgAbzOv0sfqqtYGSdU4pHg+4Guq9
         gYhWhC/TJKaa7fy9wPfFDW9snwgCMxCdjeKWZGMzdx80/tLKWnAO+xvlkXrpugjFmMv8
         ym2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=3VovhBSTW3HniGg4Z2OKgLJaVgk+mldhh4mTxqeNiiA=;
        b=XSoVXNVx63CJwJYQiHq6NsxCQdOxUuX96LlubTgcnAXOibqBa8tQp7N1D+NLNAtP7L
         bZSpg/IsWn7jRZ2Npma2QPf1QHszdMs/dXPA3l0+wxtOWmT1j7dXTCwpyYDR6ZoeQpKu
         6DfxX189xAyU85HLPqzTMvEI8zwA2i2Ijj07DAB5XAEml8evSrT76CerEmHiMAm1xcnQ
         BEsojuaeltZP0Hreyt5roW4Og01KGcMSjpnJ/LpJGinjGOQjmr71dtluo+glrPwHGa1v
         d9Nj2uJDdNkBcesE4IuBBPrJdjMaTB4ialfncfESbvxx9V5ZNqvS4ec9xxXR0ONfxcFS
         CnyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w27si998357ejb.220.2019.03.13.14.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 14:06:10 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D7F88AB71;
	Wed, 13 Mar 2019 21:06:09 +0000 (UTC)
Date: Wed, 13 Mar 2019 14:06:03 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] Using XArray to manage the VMA
Message-ID: <20190313210603.fguuxu3otj5epk3q@linux-r8p5>
Mail-Followup-To: Laurent Dufour <ldufour@linux.ibm.com>,
	lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>
References: <7da20892-f92a-68d8-4804-c72c1cb0d090@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <7da20892-f92a-68d8-4804-c72c1cb0d090@linux.ibm.com>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Mar 2019, Laurent Dufour wrote:

>If this is not too late and if there is still place available, I would 
>like to attend the MM track and propose a topic about using the XArray 
>to replace the VMA's RB tree and list.
>
>Using the XArray in place of the VMA's tree and list seems to be a 
>first step to the long way of removing/replacing the mmap_sem.

So threaded (not as in threads of execution) rbtrees are another
alternative to deal with the two data structure approach we currently
have. Having O(1) rb_prev/next() calls allows us to basically get rid of
the vma list at the cost of an extra check for each node we visit on
the way down when inserting.

Thanks,
Davidlohr

