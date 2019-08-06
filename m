Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D475C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 02:10:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA8812147A
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 02:10:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA8812147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 485FF6B0003; Mon,  5 Aug 2019 22:10:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 436D66B0005; Mon,  5 Aug 2019 22:10:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FE276B0006; Mon,  5 Aug 2019 22:10:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E88E6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 22:10:18 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id n19so47654983ota.14
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 19:10:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=tQX9MurGiQLcuHKEu+jVXFfbyrUikSawVnABrZ+VLwc=;
        b=oG+G+SU2hAXmdH1d/Df1UW5ulsnbSw9H9/397NQ4BG6eM04eYQFbJ4cZyrWv01ZQ+o
         zTQknBzrpc5oHZAIpY2Y1+KrZhO/B0JmLueSd9QmnIHK3Y9f2fGLz9jfDXvoGTX2czre
         suQNSClDo1/SvBH+dFKapkpNyQnWaIRmcbrRYMV/46Zh5HGbdI0Z4lbP9bB5BPbV6Qe0
         vUjj+Mu6TP2cNqpdsfyMEEWZ4sxzx+JPnh9Viuubh06OL2Zy66NCScrKjsmby2Mas7eH
         EMuVIrlktF4kWkDaMUqtRVq67rCSZkunk1pIMG/kIUcvLZ90FtHwOpYHHNVxbaONZNob
         kKQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAUCXtMwwaNgyw78RZEDoes1BaPrcnP4tVW3vUyxgRht7F1+lYLC
	JkGpHvilJfG9kkfQ8Hqha1xTEsm33MWrJd0gzhQtu3buhxfSosMyi9yZfOFLM9Is5NN0Ufl6d5b
	9vLVzINTX7cwQ3+cSuSIv87M9FbOr4Qeit3RtfYPoGr0RPLjFRH68J0cnjuljHwGIvQ==
X-Received: by 2002:aca:cc85:: with SMTP id c127mr78853oig.81.1565057417696;
        Mon, 05 Aug 2019 19:10:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWQcNRffNnJkzU5GMgj/pXFSvmbwL9GARaJFScpZITIbq+m6cC681kfvb9f56q2CV1OxBs
X-Received: by 2002:aca:cc85:: with SMTP id c127mr78834oig.81.1565057417033;
        Mon, 05 Aug 2019 19:10:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565057417; cv=none;
        d=google.com; s=arc-20160816;
        b=a+U5lHd7R72P7ESkXREKthpS/hX/vwCDL6ah1wtD03kAlaxgZOWCnhVb9sKb+25oSc
         6H190k+ku2WEnBcSoybK6qspP5YoHmsh4QkCn5fteStj5VgD2RSy+kujzjOscDF9LXGX
         LFYMrJMs3GWPbJn/vM3/BEFieupP0xmQQKQe7lvKtmKJQFGNloJdxHafGweL+yQ1C+eG
         165I6fEz6qV8v65X5oewSeYoxbT2z4rhzu2fyIPFLQRHlWLZnMNCFQv1lhfSUlVnMZ3s
         4JZCilL7irc+2X+6Q227zikIUGl1CUjXv6UIHE1ZRDrxQpLBKRye5p41oL1QbWTnxggu
         hpqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=tQX9MurGiQLcuHKEu+jVXFfbyrUikSawVnABrZ+VLwc=;
        b=yyIx2+gUegcJRrHqgX7almVJ0LTueHGuIhx0OtkBq1inFvrNh1oaTEy22bSC7VTmuN
         ZM0OjZ6oN2jMQkw4cx9/LROAwlLcOWvj2xkFK6HBOG24vOBJf6ZVjSf+5IvtltnrwJ1T
         Kyiy80lZM2iNMo81IW7eS1ElOhDBFIDZqMxvOcE+Z8/DabVogXGs6oXYTyAj7F+R5cBY
         AJj2BnX6uLEHHplJfLUzsbTyhb/3A6hTku7Itj/bwhD6JOQOyibU/DCFOOE3RqR0deAB
         YS4uYnXm3748r6YEmeOgCBG5YwioRHgp8ccTO+NrBccRiOH7e05oBCbEb4CoLtQVAvTS
         2cxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-213.sinamail.sina.com.cn (mail7-213.sinamail.sina.com.cn. [202.108.7.213])
        by mx.google.com with SMTP id 53si43299862otv.320.2019.08.05.19.10.16
        for <linux-mm@kvack.org>;
        Mon, 05 Aug 2019 19:10:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) client-ip=202.108.7.213;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([124.64.0.239])
	by sina.com with ESMTP
	id 5D48E17D00007430; Tue, 6 Aug 2019 10:10:06 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 66226550201212
From: Hillf Danton <hdanton@sina.com>
To: "Artem S. Tashkinov" <aros@gmx.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel'sinability to gracefully handle low memory pressure
Date: Tue,  6 Aug 2019 10:09:54 +0800
Message-Id: <20190806020954.1356-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 5 Aug 2019 20:01:58 +0800 "Artem S. Tashkinov" wrote:
>
> I'm running ext4 only without LVM, encryption or anything like that.
> Plain GPT/MBR partitions with plenty of free space and no disk errors.

Can you try to mount a swap partitaion, say near the size of your RAM,
with other things not changed, and see if any difference it makes?

Or a swap file if a free partitaion is unavailable.

Thanks
Hillf

