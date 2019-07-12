Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55B23C742BD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:09:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17B19206B8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:09:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i30lgvwL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17B19206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C2B38E0158; Fri, 12 Jul 2019 11:09:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 773C58E00DB; Fri, 12 Jul 2019 11:09:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 662CD8E0158; Fri, 12 Jul 2019 11:09:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DFEA8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 11:09:13 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x18so4707719otp.9
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:09:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MJ8/wMSygZBfB3wNzWuYzcvp2/BWwETDvXU2IK3PdxQ=;
        b=jpQA9aiAzsIrSOVGZPo6uz9/NocHLVLs1ScOe/3jS25XjVOscqzDhtxjwMr1EMavAc
         dYvrBIRgo/nmqi93rjhXMMieGWv7YwnouO4R9k4M1nuTy70P2kTnl0RpFsqRP9kydrgd
         EzOqTnOJJWQG+jlUQzu44iXZ5AuV8oS1apQ4sZ3ibRyLoBiY+YU4/GBelS4jsC/xuHCU
         p6oaxZIN79Iyu3mY0FS6WQ4z86vDwt4EtkO1eCatZPlQV6X+4FioSQMgpjC+mAvFttJm
         SjWyV7R5/Cv8k4BlTN3851oaj/4t4n5rOyhiNEiQXcqQ4jT73EhdZ5pj29wmVHEHFF2n
         hZgQ==
X-Gm-Message-State: APjAAAWvgHEdnEv2+Yx3gQHJnRkmKFD2G5nbq4NbFyfjXxO3bYkn1Br8
	wiG4sZh2zcgXwkR8EeN3KiJ/OdQp8boegWcZ1YJ78Zolcl/Vk5n18RHZbAr5lFfizqpye8CUT7L
	3KMOU4dBKQmqrOOBOQvcyhQfzImpbmEaXoItmIM3dlU+xp1goFYQq12+4sNRM3bRj7A==
X-Received: by 2002:a9d:7e88:: with SMTP id m8mr8337878otp.177.1562944152855;
        Fri, 12 Jul 2019 08:09:12 -0700 (PDT)
X-Received: by 2002:a9d:7e88:: with SMTP id m8mr8337821otp.177.1562944152179;
        Fri, 12 Jul 2019 08:09:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562944152; cv=none;
        d=google.com; s=arc-20160816;
        b=bHTdM/f/gkDFCshCc6F5jHFd4gl90zELVAh9vRa9ErbS0NhrkPMr9F3ZEAacLe8KqQ
         zr7CfdOgsjSIDdvejEII1zWkOLYOowpX1xkhIj0cL+fIyeAh6CS0Vl3ejK/LjAGQ9Aqu
         jXJZKHm8ZuHGdwwTbNUgY9vnlY2DvN0FwKj9dt9AJ/o/MrOGsEwfQU5NrA9tyUrnlfg8
         y2OdyGdv8JBsQO+vMRy+HMeJbfZzYb+grNjYZj3WvqnEOFNFXOVyespRyWDgGuiEsOZP
         vXt7O4orw+u9dGKzEpy5/1U3Qnvjdl4Bgy+8SsJLBS0vqHrf3+JwWWLYB3R8Qdzj8KHq
         pZNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MJ8/wMSygZBfB3wNzWuYzcvp2/BWwETDvXU2IK3PdxQ=;
        b=R58DEjDv2fO9JeXsckGuF6ex5eMRM+CdzMdVKGi+wNpDBkz/KWSANK+XpvHJyS6Ai5
         i9A6n4e/Brq4ax19662yFMPUeLnjiDFDfJon0H9ahKRkjxRy47FGcGenUoKFKhvIl97D
         Y0rKqxZ2h82mFNLtjN49py8Bi1V8Z0nCYddIlkCgyeedlnzwheyHBgeNQb3MsHMKIkTF
         A1ZHZ67Uns55jmxXlJ71OJ4KmhjKwhh7ZxKtQN4yvBFOwHMYnyJuVh6nxF14/JJ5KmCt
         bNmx4MqR8ihn1V8MlpJwI0Ou6vPQrlwGtPFKTQHUWRRpP00KWHCY+C2zmRpm7/+y0Uzc
         cMgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i30lgvwL;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r136sor4442608oie.105.2019.07.12.08.09.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 08:09:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i30lgvwL;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MJ8/wMSygZBfB3wNzWuYzcvp2/BWwETDvXU2IK3PdxQ=;
        b=i30lgvwLkeVpXQsVjPYonpEPiGWlUBv2z2qDgJQMxrpKENxTorJSehxeqy+LUhfYzv
         VtQK7axqN3W8U1LkXDuWZF1uP/L2p5KuLxKw4qI6wW++8B5fsIOnjjNBcW6teOiQ7tII
         mzaCC2ZUY+uYaRDsXXA4s9KcaDlBUAOOWLZdYfvJUEAQEBDrP1cVZ7aiVZqE4JPjLspM
         gGX5Sxlw25a4BwETR5XcKtZkSZrIlIkMg/I5T2vbeOKWQ6GxTtCPuP3CCKEjJvhuAnNI
         gUc8VfcZTZNpYUjORWUUYKbazILP48oH1baF5oAlWmAp2Iq73gk63PjeR6tPL6TgX/5n
         EdVg==
X-Google-Smtp-Source: APXvYqx6mGiQZVnuJ8vBdqFSeKXfLAml4k5LUaP7pbQDRWmiFpLAtMv5q6hcSKqWv8vY99TgvNNCYqHMtYCIHspx+74=
X-Received: by 2002:a05:6808:4d:: with SMTP id v13mr6048794oic.22.1562944151822;
 Fri, 12 Jul 2019 08:09:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190712120213.2825-1-lpf.vector@gmail.com> <20190712120213.2825-3-lpf.vector@gmail.com>
 <20190712134955.GV32320@bombadil.infradead.org>
In-Reply-To: <20190712134955.GV32320@bombadil.infradead.org>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Fri, 12 Jul 2019 23:09:00 +0800
Message-ID: <CAD7_sbEoGRUOJdcHnfUTzP7GfUhCdhfo8uBpUFZ9HGwS36VkSg@mail.gmail.com>
Subject: Re: [PATCH v4 2/2] mm/vmalloc.c: Modify struct vmap_area to reduce
 its size
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Uladzislau Rezki <urezki@gmail.com>, rpenyaev@suse.de, 
	peterz@infradead.org, guro@fb.com, rick.p.edgecombe@intel.com, 
	rppt@linux.ibm.com, aryabinin@virtuozzo.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 9:49 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Jul 12, 2019 at 08:02:13PM +0800, Pengfei Li wrote:
>
> I don't think you need struct union struct union.  Because llist_node
> is just a pointer, you can get the same savings with just:
>
>         union {
>                 struct llist_node purge_list;
>                 struct vm_struct *vm;
>                 unsigned long subtree_max_size;
>         };
>

Thanks for your comments.

As you said, I did this in v3.
https://patchwork.kernel.org/patch/11031507/

The reason why I use struct union struct in v4 is that I want to
express "in the tree" and "in the purge list" are two completely
isolated cases.

struct vmap_area {
        union {
                struct {        /* Case A: In the tree */
                        ...
                };

                struct {        /* Case B: In the purge list */
                        ...
                };
        };
};

The "rb_node" and "list" should also not be used when va is in
the purge list

what do you think of this idea?

