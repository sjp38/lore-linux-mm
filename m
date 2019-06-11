Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2596EC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:19:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9335205ED
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:19:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9335205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A1E26B0007; Tue, 11 Jun 2019 10:19:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5522B6B0008; Tue, 11 Jun 2019 10:19:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41A8F6B000A; Tue, 11 Jun 2019 10:19:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id E946B6B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:19:11 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id v125so544068wmf.4
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:19:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=5c5fLTWuG7H0cAYW1nFOWqDzGLiH4vgxzMrE5FX75+I=;
        b=cmGbiqq8u+uHTdH/6waJy6juRRV7NZDWsQk5CmkcvRw2G1dI40SjxsySTdepNN+wcz
         wVAcY4v4qg2XNnw+TL6It6qcSL/y7eHT/k26yYQ1eMscv165rHrZPJBznW8fBDUMoDOP
         sUVzv/tnJPXyLQayaLLe7WST4X0/6NqOK4MbOsd/56quke60AOmZqxo7IbXbI4XFhV3U
         dIyKqF5sc0UZ+9hiL6nWVkwRQFekKUM0dRqVdP2tIOVSxcnopDpdpEEoht+JZjoUgZ86
         Qnh+UFij+oaRYjRjMhwhDhXYvDlZXys9YXtBu5bv9Czsj0P47vkbGaoZwmdi2sYUof+O
         R+sw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAX+VqtCGilA4jqqnN74jU1TloU9R8VTaqu46npyHz1OC/+ct1mu
	/wBW6Z79wDK1sxLFbqs6qXFX/yYEloP6dnK4cJHDBoGurghgAHOQJOxuqlQoss5AW+QN3cXNLF5
	QeKMXhYYNO5XM+OeIG2EksdITGTJqYPYWmSndq0CfzW3tLEKxiqjtdbgRLSp4q0xEZw==
X-Received: by 2002:a7b:cc0a:: with SMTP id f10mr18949796wmh.81.1560262751491;
        Tue, 11 Jun 2019 07:19:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzk4BCHw8wH1XtSWFF7yVgXXefVwrvJ+Ls+ef1c2CaacOP99vvoL9I+bRgoMEY1sbu6+1xa
X-Received: by 2002:a7b:cc0a:: with SMTP id f10mr18949705wmh.81.1560262749914;
        Tue, 11 Jun 2019 07:19:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560262749; cv=none;
        d=google.com; s=arc-20160816;
        b=V69qsizMt41292vOc8TknweqHgbyTF9y9uorEFtwfxsQhZvViy8RdIgLYBd3xIhugB
         /44Luv3mD68KnW1fDE9uBSqbP+Hsra5gEZFw0z7CIfqSRPhSmIM1Ao3QYm5leHRPpQVa
         scKM1OalGTu1kEiamlxMocqNCPfceHccJp7CjUH5pALE/XrdVgl6BPqo2DU0qsPSSDNM
         ekdkXDdJj8MRoK4YptQltnzvy5pbB9j7qePEBfpGOdW2t03VGvZhj/8QhVR3Wu29IKzb
         /XsMmf5F/e+cs1I39SL2nI3Ts059MdM5YwcOTxSYzBalIDoKsjgytinwvxwFAY12lxmY
         4JJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=5c5fLTWuG7H0cAYW1nFOWqDzGLiH4vgxzMrE5FX75+I=;
        b=sixxQtyaoun5iS8soW/nDSGDjOa8OYS9877j9LUeCE96Sy0bzV3IwVZpir3ER5jgma
         uxpebG47qp/BPpXHoBE/pK7LV+S9QXhIz/JyOhV1RIdy9mNEvnNt3KEzKLBUPcHOeYOl
         sqBMj6ZBhUeGbBOjT5dpnj9KiBvlXiPZtFr/HyCsvBfiEWrsmV7V/tvIrZTmLyzaoh6i
         WBOa8YA433WtOFf3s+J6yXbeQCzaJ4beymOY7Ca9aXwf/knSkx43vUSjDTVjFT9eEpbQ
         s6+ve1brULHz3LQV5lKosLMI9YE9YCJYOYboZ3nxmLoszyOJwDsANnCdDkilJlFXxL9D
         Kk+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h1si2080489wmb.105.2019.06.11.07.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 07:19:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 3E91868B02; Tue, 11 Jun 2019 16:18:42 +0200 (CEST)
Date: Tue, 11 Jun 2019 16:18:41 +0200
From: Christoph Hellwig <hch@lst.de>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
	Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org, uclinux-dev@uclinux.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 02/17] mm: stub out all of swapops.h for !CONFIG_MMU
Message-ID: <20190611141841.GA29151@lst.de>
References: <20190610221621.10938-1-hch@lst.de> <20190610221621.10938-3-hch@lst.de> <516c8def-22db-027c-873d-a943454e33af@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <516c8def-22db-027c-873d-a943454e33af@arm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 11:15:44AM +0100, Vladimir Murzin wrote:
> On 6/10/19 11:16 PM, Christoph Hellwig wrote:
> > The whole header file deals with swap entries and PTEs, none of which
> > can exist for nommu builds.
> 
> Although I agree with the patch, I'm wondering how you get into it?

Without that the RISC-V nommu blows up like this:


In file included from mm/vmscan.c:58:
./include/linux/swapops.h: In function ‘pte_to_swp_entry’:
./include/linux/swapops.h:71:15: error: implicit declaration of function ‘__pte_to_swp_entry’; did you mean ‘pte_to_swp_entry’? [-Werror=implicit-function-declaration]
  arch_entry = __pte_to_swp_entry(pte);
               ^~~~~~~~~~~~~~~~~~
               pte_to_swp_entry
./include/linux/swapops.h:71:13: error: incompatible types when assigning to type ‘swp_entry_t’ {aka ‘struct <anonymous>’} from type ‘int’
  arch_entry = __pte_to_swp_entry(pte);
             ^
./include/linux/swapops.h:72:19: error: implicit declaration of function ‘__swp_type’; did you mean ‘swp_type’? [-Werror=implicit-function-declaration]
  return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
                   ^~~~~~~~~~
                   swp_type
./include/linux/swapops.h:72:43: error: implicit declaration of function ‘__swp_offset’; did you mean ‘swp_offset’? [-Werror=implicit-function-declaration]
  return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
                                           ^~~~~~~~~~~~
                                           swp_offset
./include/linux/swapops.h: In function ‘swp_entry_to_pte’:
./include/linux/swapops.h:83:15: error: implicit declaration of function ‘__swp_entry’; did you mean ‘swp_entry’? [-Werror=implicit-function-declaration]
  arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
               ^~~~~~~~~~~
               swp_entry
./include/linux/swapops.h:83:13: error: incompatible types when assigning to type ‘swp_entry_t’ {aka ‘struct <anonymous>’} from type ‘int’
  arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
             ^
./include/linux/swapops.h:84:9: error: implicit declaration of function ‘__swp_entry_to_pte’; did you mean ‘swp_entry_to_pte’? [-Werror=implicit-function-declaration]
  return __swp_entry_to_pte(arch_entry);
         ^~~~~~~~~~~~~~~~~~
         swp_entry_to_pte
./include/linux/swapops.h:84:9: error: incompatible types when returning type ‘int’ but ‘pte_t’ {aka ‘struct <anonymous>’} was expected
  return __swp_entry_to_pte(arch_entry);
         ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cc1: some warnings being treated as errors
make[1]: *** [scripts/Makefile.build:278: mm/vmscan.o] Error 1
make: *** [Makefile:1071: mm] Error 2
make: *** Waiting for unfinished jobs....

