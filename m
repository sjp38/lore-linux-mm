Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D46AEC04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 20:57:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86CFA2085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 20:57:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="deYS98jc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86CFA2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C7A16B0005; Thu,  2 May 2019 16:57:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 276756B0007; Thu,  2 May 2019 16:57:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 166296B0008; Thu,  2 May 2019 16:57:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A89496B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 16:57:37 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id b22so640943lji.7
        for <linux-mm@kvack.org>; Thu, 02 May 2019 13:57:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=pBJ9w6lgY/gbDSyW6tu8FbPiPrRqqN8hgCcI/ouWv4M=;
        b=RY+SvBYXRLCPOQM2J7neSKDV02xcpiF/DbFQnW0hGmHH8AIQR0VPlr2l1FoWLpo8CD
         XaIcy80A+vJHuVGyjPELZb5yeP8WBF6csYi1a9TaSKFWcHpdpVLu2pdVTWocpXjLYtzP
         RWqT7C49QMU++rIxaVeCobaXYXtFItmPeWMfGdDZfu7EwljZLZr8DMShZSVlD8p6PO5j
         Cs/JWZwtc1h+lSeDp6u81ESKRDpDM9JmM+ItHeqweo8NCbNVKxD3pr3c4L/Zvh6F1JuC
         eh6/Izw2kI1aaAlwKmMlV7zmqmlN/VVlvabmL7ne7IzWmKd/dBMCLHZM6Vj1Fahw+isH
         q1UQ==
X-Gm-Message-State: APjAAAUdDN4STRIAMJvwdjjafRSg3UPTusGJui7sj1T2vCHGqhtihm2r
	ze4v8DVMwsv1xxf/12jPnwkaiGfSt5n770a1LEcwETPBz87N7XL2DgajMKOQNYYkQszcXPDSyT6
	U0Mrfn97B+rrhmtzw7ugRTfiCpaWfco++f/HrWLrNgerXC5QQPnCMX4ycX6GgBeH0hQ==
X-Received: by 2002:a19:40d8:: with SMTP id n207mr2957827lfa.70.1556830657101;
        Thu, 02 May 2019 13:57:37 -0700 (PDT)
X-Received: by 2002:a19:40d8:: with SMTP id n207mr2957804lfa.70.1556830656245;
        Thu, 02 May 2019 13:57:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556830656; cv=none;
        d=google.com; s=arc-20160816;
        b=08OkTwuhwBVp/1JW5lxDDw3sUJYVSXygmFuCB66X5eddanZ55qvY49vzAZPW630C3H
         uyWyu1dUaWnjwedTkkSlW2FyqfBjf7XDjbAgjdOLEdprMhZ8jdDvxOQ9iVoTmWRUJVGZ
         C+QBEobSoU56bPmZRUSQKO/wgMOWXDERs7sdOJ/7lSkSYeT9CQCcwDJq+wHn4a4RAcG4
         KJ3JhoiS2VTFkdUReuJft8nxdAFu8pDPeCioEsead52LLeSFY0u3CTa35tIpCtuWaoEu
         ITGP+iGi7X/Un/M3bIRjWFGidtV+GechXOemiPOG5E69KjCkr9d5iJnUAr4kHFlwGRFH
         uSQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=pBJ9w6lgY/gbDSyW6tu8FbPiPrRqqN8hgCcI/ouWv4M=;
        b=PVgzG+WzC9jLPPQw/zBg27As/aU48VHa4caUx3ki/IVvYkYac90xW9oabkLQCFL3HR
         s/9DH2UQYhj09lX+lUVwDydO9Ej34SzZVES1ucVs6a2mU9zXSjRHbdqCRgzs5GeiB3ic
         AJyHdb3hOoFfXrfqYvjS1KAiFVNNLqfIF6VB1XMyt9bSZlvWTJMCndjrFTA8yZi6MiNy
         fYB5OkN55ZGJK5aht2gbFp9LI3PRA4yuNNWjLOXKua51oEiAX1vlLBZ7Z0Oo8hYNfUiY
         zM70615mluoUf0AlP1n3qjGt3fFfQcZRyk1ugcbUPSW2s85sV0IECQfOUBWQKRPTh8Pw
         N5wA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=deYS98jc;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor129600lfb.28.2019.05.02.13.57.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 13:57:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=deYS98jc;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=pBJ9w6lgY/gbDSyW6tu8FbPiPrRqqN8hgCcI/ouWv4M=;
        b=deYS98jcrPo1YtSz5GL3B0iQfozu+v1yEvuPzAsdsWGhfbJyvv724RHPDCPBBUz193
         YmuuZ+3J9FDyqp4UAwMQnt6Danwa/3aTV1V/HxcOnba0F5DXgFVk8oJcsWcEBkao3Wau
         TDnrwHrKm3VF+k3A+EikcEYFO60/XJVCPvWztbFMfjxcKEDbQ6O5UvIjRLKjAhTcKMeg
         gWN4c3Y6aFwxybH+m+zq+OulOAjA6Fi7S2F2PDtnO/K+i+CDvNMhWXzzp1X8VRuAkqXM
         6ybTE89hB3ATBTkF4BitNCuLpA1YRtrkGikfV8/THNgtw6c/rGI9wxPDTBznvH9+NEkS
         5m8Q==
X-Google-Smtp-Source: APXvYqxpwSHaqM6yCkiO3Pu3fwtOtpblG0k9kQIfYRQCf8nihjcaltZKVv+2R0xqJFSn+bFWlEOiAQ==
X-Received: by 2002:ac2:5307:: with SMTP id c7mr3062605lfh.58.1556830655847;
        Thu, 02 May 2019 13:57:35 -0700 (PDT)
Received: from uranus.localdomain ([5.18.103.226])
        by smtp.gmail.com with ESMTPSA id j9sm11251lja.92.2019.05.02.13.57.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 May 2019 13:57:34 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id 4DA9D4603CA; Thu,  2 May 2019 23:57:34 +0300 (MSK)
Date: Thu, 2 May 2019 23:57:34 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
	geert+renesas@glider.be, ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
	mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz,
	ktkhai@virtuozzo.com
Subject: Re: [PATCH v3 2/2] prctl_set_mm: downgrade mmap_sem to read lock
Message-ID: <20190502205734.GE2488@uranus.lan>
References: <0a48e0a2-a282-159e-a56e-201fbc0faa91@virtuozzo.com>
 <20190502125203.24014-1-mkoutny@suse.com>
 <20190502125203.24014-3-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190502125203.24014-3-mkoutny@suse.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 02:52:03PM +0200, Michal Koutný wrote:
> The commit a3b609ef9f8b ("proc read mm's {arg,env}_{start,end} with mmap
> semaphore taken.") added synchronization of reading argument/environment
> boundaries under mmap_sem. Later commit 88aa7cc688d4 ("mm: introduce
> arg_lock to protect arg_start|end and env_start|end in mm_struct")
> avoided the coarse use of mmap_sem in similar situations. But there
> still remained two places that (mis)use mmap_sem.
> 
> get_cmdline should also use arg_lock instead of mmap_sem when it reads the
> boundaries.
> 
> The second place that should use arg_lock is in prctl_set_mm. By
> protecting the boundaries fields with the arg_lock, we can downgrade
> mmap_sem to reader lock (analogous to what we already do in
> prctl_set_mm_map).
> 
> v2: call find_vma without arg_lock held
> v3: squashed get_cmdline arg_lock patch
> 
> Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Mateusz Guzik <mguzik@redhat.com>
> CC: Cyrill Gorcunov <gorcunov@gmail.com>
> Co-developed-by: Laurent Dufour <ldufour@linux.ibm.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> Signed-off-by: Michal Koutný <mkoutny@suse.com>
Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>

