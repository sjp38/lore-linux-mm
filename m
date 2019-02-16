Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72B54C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 12:19:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07F2F2192C
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 12:19:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E+iNgYM/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07F2F2192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 551D38E0002; Sat, 16 Feb 2019 07:19:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 502A88E0001; Sat, 16 Feb 2019 07:19:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A5368E0002; Sat, 16 Feb 2019 07:19:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E832F8E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 07:19:55 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w20so8821613ply.16
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 04:19:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gHEPZX+eAeUOrKBJcAwKFbRXlTsai8Ntd4iZKXNgWL0=;
        b=gPy7bIl+CcmSs/yISgp7E6bMmqDL8spTy2Hgy96R7D3rnyU1CBNzmSAQ0LkSyaKJlt
         LUXAi+X5Tf/wiSuT+wV93wf6tXY81UzN8Ali0yE/5lChntIjLd6nLtRRm4v0O8kzXd9J
         VkiwPcasROHHvBAGxUXVtQM9h4zpGGACCNP3Dg99+BNql+vgf8klzGNjB0GeMHs42iQ/
         pSDiIcvoiNoZp61ROLCBI9o2tU0eQ/t+uI8bUO02wkR4uOXYvNFtEW06JutWvUyMOj1Y
         dFmvprxhBsBWvravVTynF6LxS5pNkjTiAsi90E++yWn1CW1xF0W3/XGOBkgtYFE7iwlw
         D/sw==
X-Gm-Message-State: AHQUAuYdZ8UQ52/Uqc/uRvE3/z87lLj9wR5tGsO+3kNh5r73Dsmyx6ut
	5tSmkP1HSw3KPJjwRMCqWPuxiaZ5a0M5VOtYYYc/e9ug5K4yFs5t/NgADaXEpQpppbmyQdq9SS2
	DLQIyIB1mIVagvlH8N0P1femHpLRCESGhrC1VMAWpheWBQSJ14JMYrVMh7uAoIR1gr/l4RBNjwh
	PPN3PjEPKK/GXyk7HqJr1hxROMVpjOitn2llrBhi0Z/x/9Q7V3/gm3gl9PxoYggHmXDtd1iDv00
	w9dxir5O30WfwKbdfuchOuOSLsalvxvFmHrdqIAxWpK/89ms3Rx1KX0WxWHAny7a+BKuUZJMhhw
	ZC8cub0DHnp9Vcyd+Ads2xe4EAM7NEOIhbEToPS2ld6wgRWJJ3DPUl+eQTTazxfqc7uERystmMD
	K
X-Received: by 2002:a17:902:7683:: with SMTP id m3mr15281232pll.191.1550319595120;
        Sat, 16 Feb 2019 04:19:55 -0800 (PST)
X-Received: by 2002:a17:902:7683:: with SMTP id m3mr15281194pll.191.1550319594373;
        Sat, 16 Feb 2019 04:19:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550319594; cv=none;
        d=google.com; s=arc-20160816;
        b=efFnywUpJp4UTJloKvzuIDmfgdySiVslCUX+f3UINxhZxWNbtqaOFMsbGrpk0I+cxL
         /p/em6JbGwYiYo6JvXlCdE7rNsPDP5XJtlJzU29kmS52U/GgFpByfZK8LW8O5Za/SknU
         +upLqN/X2c7rYqhOWMFO7lv4YmeXK/WlqHLZyhFqXENwkOran6Y5pvaRgisnJF4/3MR8
         qphVh/6XshO/H+vBG3dLjgcCopkNv9J4E1LZCGoZyIxqDw1wntHwMfd0DqEJDPrLXcgZ
         iSdfrWEKuhrzueWN8AnGc4uATpIxqw8M2xvOLPC+mhyxcHP/dF+pbZAvaySiYAN5I0aD
         TuqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gHEPZX+eAeUOrKBJcAwKFbRXlTsai8Ntd4iZKXNgWL0=;
        b=bPLX7ClWjC5Tn7MEztSB9KaBBTeUOc+OOBfSHZRQPfKLwIbyZfaOd+R4v1E+qzMMWm
         fo6z7kcoYSDyYntircAymhfK7RRrdKs7AuqDnJnefMC/exOnl612T3/TYOQyYzFN1yRc
         +BLH2m4hVOothdWlm65apAg9rqZMdJ4gQO6c5D+2M+4o7BqZNX7AYXD+fiOlLOKQqvvB
         3eFETaFBGzrC97kCgyeERXRHZFtS5P5veEC6m6IkKEH5JWUXtqgYG3HztkLAwspuM2dF
         /6DjO7x33TrgS15Og3LmQgKakDGr7K/JeOhQ3PppJdno6SQgRZgbYz4HpW5e61SuZnnM
         h1Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="E+iNgYM/";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 27sor970409pgs.8.2019.02.16.04.19.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Feb 2019 04:19:54 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="E+iNgYM/";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=gHEPZX+eAeUOrKBJcAwKFbRXlTsai8Ntd4iZKXNgWL0=;
        b=E+iNgYM/WhcYH71Brv5YHi+oKrscgVihtOz5SqKMT2cLjk2/jfSpuZ/uuel9B6G34M
         1vGwWSMD6m5haCaqFec23uxgxBH5ae6ardjraHmZ5ePba227yhz9baPRHfDG7KDedqoN
         ilns2CQWc1YB5Uf0yeJLJ+2kktSqP65vf3RYrNnE1iTY2KxfCog25rL5NWGa1FR+Q+6E
         Nshiaon9iX1rhKnQXn1o2EQvwgmeJUnhJTgUGyjEmtwF3anVba/zTNIhui2NwzX30KTq
         I6WkVwvlytelWk/++16Op9QOjqS2RjjKWNsHFtCKojiCvubqzLuWVnlVBUvamSNPVZrT
         RlSA==
X-Google-Smtp-Source: AHgI3IbG8z36UUMNV7ceaH7vzxYQll4rXqo2PJTRjGRSdTCiyc6BdYv7Velr218WowYx55PX3Dt99g==
X-Received: by 2002:a63:6881:: with SMTP id d123mr9826927pgc.10.1550319593434;
        Sat, 16 Feb 2019 04:19:53 -0800 (PST)
Received: from localhost (123-243-232-193.tpgi.com.au. [123.243.232.193])
        by smtp.gmail.com with ESMTPSA id l81sm19756189pfg.100.2019.02.16.04.19.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Feb 2019 04:19:52 -0800 (PST)
Date: Sat, 16 Feb 2019 23:19:50 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
Message-ID: <20190216121950.GB31125@350D>
References: <20190207072421.GA9120@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207072421.GA9120@rapoport-lnx>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 09:24:22AM +0200, Mike Rapoport wrote:
> (Joint proposal with James Bottomley)
> 
> Address space isolation has been used to protect the kernel from the
> userspace and userspace programs from each other since the invention of
> the virtual memory.
> 
> Assuming that kernel bugs and therefore vulnerabilities are inevitable
> it might be worth isolating parts of the kernel to minimize damage
> that these vulnerabilities can cause.
>

Is Address Space limited to user space and kernel space, where does the
hypervisor fit into the picture?
 
> There is already ongoing work in a similar direction, like XPFO [1] and
> temporary mappings proposed for the kernel text poking [2].
> 
> We have several vague ideas how we can take this even further and make
> different parts of kernel run in different address spaces:
> * Remove most of the kernel mappings from the syscall entry and add a
>   trampoline when the syscall processing needs to call the "core
>   kernel".
> * Make the parts of the kernel that execute in a namespace use their
>   own mappings for the namespace private data

Is the key reason for removing mappings -- to remove the processor
from speculating data/text from those mappings? SMAP/SMEP provides
a level of isolation from access and execution

For namespaces, does allocating the right memory protection key
work? At some point we'll need to recycle the keys

It'll be an interesting discussion and I'd love to attend if invited

Balbir Singh.

