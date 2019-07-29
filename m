Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66B31C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:18:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3517720644
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:18:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3517720644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D65AA8E0003; Mon, 29 Jul 2019 04:18:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D152D8E0002; Mon, 29 Jul 2019 04:18:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C04108E0003; Mon, 29 Jul 2019 04:18:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8825E8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:18:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so37770026edd.22
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:18:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zv1jyHrQhg/anG79DXIg6d42L7l6b6qBUMNYIf//wxg=;
        b=ZIgtHLUMi1FkKui1tiYW+lFJHrd9PdJenx++vs9ufFolTGI5B6B5SrInyD9evhNxOT
         bj/OXi2Gc6uIJwHlPtqy8atKFV4CnZ3bbVoyNG58eT4VT+sEQXFQR6hiaSrgWbiyMpsg
         c1iK9KthF5mey4Fh0SZdVH+qfmMpdz3dKFxovywlL0AyIrhXg72rQUi0X/hlEg4va8qO
         yV335A5ia5ukWW2L4oaZDbJiiLt4U9Z/7qXvTxcAkyUjzqp4Uf+0q4WdrrB9AbMVdzIt
         zTO+9taqAbW8NCT1/KBopNeHXHmtno/YkvRSdY3zixmbZ4VRtoZlHCkh82X8I2jE44lq
         Cupw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of qais.yousef@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=qais.yousef@arm.com
X-Gm-Message-State: APjAAAWOabJtPMygeWzCasZWuEBQuFyNi/nNwSeGhYsxncVilIeFTPI9
	ivu9rv26UvI8E/BvafqdK2bGbQnH7vxyN5IOowiO1zrJJPRv/sbkmvtf0A8ST2YGPjbGCU3wqwV
	+OegaMfNfwD4U7rymxWHI+N7nQ7r7CubJ0K0AbeHhe69mqaI7+LU9Z2IiDZbT9KRJxg==
X-Received: by 2002:a17:906:6bd4:: with SMTP id t20mr79755275ejs.294.1564388286104;
        Mon, 29 Jul 2019 01:18:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+PDzwO6O7ec0nxWP6AznZVgCuNGS36odH9RDkrStEvsBMEb78vFpB62wvNUxnQBAH9TqZ
X-Received: by 2002:a17:906:6bd4:: with SMTP id t20mr79755238ejs.294.1564388285329;
        Mon, 29 Jul 2019 01:18:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564388285; cv=none;
        d=google.com; s=arc-20160816;
        b=r3AC22Woa18aZAUjkPuQUdXw3//UcWj1zPKA1iK466RFPwfrJOu8Y6LdHNVD2Ogls1
         K9hj50yQuuHcCiIdLuFCZS0r3UUAklk+e++jWhWCoXbKslU9yJx0ZfxQOO3irWkz/SVr
         Yw9kE5ujeHeOXTr4pPSDdjjWqDLpbu+854cDeemIL+3sEL0VrjAIBqfVPPoUf6cIawqd
         uL674AMuMqNVMFRh0UO4RHaKQYI0b+Xu+OoUPOijc4F2PLH7k14+wVkDEj3SXPO93STn
         ohw+rruBTeEgWMfOm/5/y19fjLce5gqFeP1OqgFCDMY7oo4sV9aU+myzIziHWpWeUa1T
         Yd9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zv1jyHrQhg/anG79DXIg6d42L7l6b6qBUMNYIf//wxg=;
        b=xACcx3QEAwghnMpOH3XJynE3iJ6/CswSDpZ0y53IraCEtoqNfhfTKGTTuLmUDo/Dx7
         nU7YIZcZKpBF81XeYaizLjHruZs+ACLpeOttUEUPG1gn1ia8QBB4e9t9VimXMV4wIOiK
         iVDeOhh2+nWVgi99zoK7rFuMC05mmbA7fAnomD1C9/4ZAYXgtJPqgG7C9lH50I2+59RH
         gBZ9bSHBku/KtcEoQ4uJyWaPBmuhbCA82KcYG+P9Mcf5BXo0JMq/U0q8j0zZldMCiCvC
         zmfyEG8i8CKUUieJiaeif9evrNLUAJ0m43QqELhWFErW7Us43hzOzdRWycNWrzda02hW
         fbFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of qais.yousef@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=qais.yousef@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l31si16933003edb.143.2019.07.29.01.18.05
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 01:18:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of qais.yousef@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of qais.yousef@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=qais.yousef@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7D12E337;
	Mon, 29 Jul 2019 01:18:04 -0700 (PDT)
Received: from e107158-lin.cambridge.arm.com (unknown [10.1.194.30])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 78F283F575;
	Mon, 29 Jul 2019 01:18:03 -0700 (PDT)
Date: Mon, 29 Jul 2019 09:18:01 +0100
From: Qais Yousef <qais.yousef@arm.com>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190729081800.qbamrvsf4rjna656@e107158-lin.cambridge.arm.com>
References: <20190727171047.31610-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190727171047.31610-1-longman@redhat.com>
User-Agent: NeoMutt/20171215
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/27/19 13:10, Waiman Long wrote:
> It was found that a dying mm_struct where the owning task has exited
> can stay on as active_mm of kernel threads as long as no other user
> tasks run on those CPUs that use it as active_mm. This prolongs the
> life time of dying mm holding up memory and other resources like swap
> space that cannot be freed.
> 
> Fix that by forcing the kernel threads to use init_mm as the active_mm
> if the previous active_mm is dying.
> 
> The determination of a dying mm is based on the absence of an owning
> task. The selection of the owning task only happens with the CONFIG_MEMCG
> option. Without that, there is no simple way to determine the life span
> of a given mm. So it falls back to the old behavior.

I don't really know a lot about this code, but does the owner field has to
depend on CONFIG_MEMCG? ie: can't the owner be always set?

Cheers

--
Qais Yousef

