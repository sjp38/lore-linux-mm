Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D11EDC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:44:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93B77218A3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:44:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Nlp8ZXU+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93B77218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3383E6B0003; Tue,  6 Aug 2019 17:44:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E8FC6B0006; Tue,  6 Aug 2019 17:44:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FE696B0007; Tue,  6 Aug 2019 17:44:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id F22526B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:44:03 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id k21so65283665ywk.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:44:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Xj5yWDm+drkTcWobF+B+SfSeu4cUAiftcsjQzbtvZZY=;
        b=b3/vR6WzwFZvef/XAU+yUwlbbJy9OyEVW/CN3BjZ5tz+l7w39RpoKy8snwGuOQqBIa
         2h4kW7DYmU1Lmy/IEBbPDXsYoTtr5jsx23Ae4egWEHCxbvWsG4QzCiXvDGHYnMidXG4Y
         oi/CCvG0GUMd+Vv1q18uBidxj69ZOzQsnYh1jxaKORVAHdx3aQYkUp8O5FWZejsi7B4k
         tg3YjANdacMHC4tEcm4faoijJmMV0JhxxyNIFAdLSN4Q40vJAOwOLI2bpwXPfFWJ4+i6
         R8Skf/uWb//IpjK0i3r3CIHRlgX1fBqMORt1vl2pKaPK7HpbVh5IwDOymK043jpNh8Mn
         8SsA==
X-Gm-Message-State: APjAAAWXXJC41RBWadJLPNLUPyGRr1yfOX/+nK2NScNJqMiSaIfkCGUA
	C4ZUg6wJtkjp8jjHtM+p0vj97R717O1d3vfFboOQhF7tMpB+xZoFxTJLdZq4YrEQe70dlTZZgAp
	n5dxOLhiT0ZvX+EUKXrWFhQ/4RZBn6z3Vw63yeqfEEU6Mn4YkKH3LMXKTBv5jUnUDaQ==
X-Received: by 2002:a0d:f1c4:: with SMTP id a187mr4033317ywf.241.1565127843752;
        Tue, 06 Aug 2019 14:44:03 -0700 (PDT)
X-Received: by 2002:a0d:f1c4:: with SMTP id a187mr4033288ywf.241.1565127842840;
        Tue, 06 Aug 2019 14:44:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565127842; cv=none;
        d=google.com; s=arc-20160816;
        b=zcVzKhkKGt2c6UQDyAfz18gqvMhXOzj9fmVPHEan6Mn/n6VC+K3am0IKL6XvN9cWvQ
         uhBYawQTN1K+QmnRO4fKY0SQfct/IKZi+genzgrKelzpdRKw5cKm7lOltZ32uhfhXgXW
         tAAch+MxYaPi2ixBUmyStKtDx6+DmhSLWlU/QAy7ggEpu20br1L99oDFQZvzzjwqUHNg
         ypYy62L4izk3Ez1g8nwwlStVQhlTDs42WKxOEb8aE9hkpjqaQUKlDdmLqjRJiEXrZz1H
         2OL30p9NnYAVmEGPGNsS6/z4GffFsg5uKUJykCUi4NyRaODz87HffRDuAaF1y+dpv6Yi
         bT0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Xj5yWDm+drkTcWobF+B+SfSeu4cUAiftcsjQzbtvZZY=;
        b=SrZEwZkvmjWdw1nHpLjkwIaaC9zbBoNyuvjg5mb3JTQI2ttmFCgwlhvnzXHqnpv0Ax
         efygnTO4c19Y+BTTHRQk4ecCbPcX3MywVBpVMZllcVWRzHw/wWMVl/2AErKYYTy9X4WF
         sDIXuY4wBTzeff5cdFa3ymcxa1a1ey6rievAEPUV/Tw3O5CrUZTa2hQzDeI+G/6UAbve
         X4jWBPszByKu5cwjO8ZJ5Xs6Ofvt03RysFEQlovsZfZ0E/B2kZfm1jVHr4YCkCljCIDw
         0HPjN/TapTmirnS4au721rQZuGNO2wOsQ015DKlwjuJgF5db7BORvYX6TOlX1dhYlZrU
         7tYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Nlp8ZXU+;
       spf=pass (google.com: domain of james.dutton@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=james.dutton@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q19sor36545778ywg.91.2019.08.06.14.44.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 14:44:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.dutton@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Nlp8ZXU+;
       spf=pass (google.com: domain of james.dutton@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=james.dutton@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Xj5yWDm+drkTcWobF+B+SfSeu4cUAiftcsjQzbtvZZY=;
        b=Nlp8ZXU+iRYXz+eicM7sucfWByTxLZlSUEMe+5TCM0kxhttbD8YZQUoFTWZunYxXmp
         I/e5wOSzrUceMTBbGN1OQmuTBK1yQQWZYghpIASRwkYcOdsdzIT9crfPdYhBnUOREvPd
         jbHe+qXPQnE98IT0H4cclpWE0x1lzeLnHP/d53ETi4wtdMc6UD+cr0bMoVgG5ZnL6ynp
         Fij+6I0DxihfeV8S+h3SanKCuoWcbO8PLk5idomALLwVkakjOytRnXyvWQg8K/XIM3Ch
         P5Z7BOxrkVbdR9/hmjTFkfKlXcpwDTHqy8XIvJnUEflwRu/ysG1KZ4aGfqrBSjTy5JBh
         5vqQ==
X-Google-Smtp-Source: APXvYqx98csDDMKW2OnhxGRVIMUeXsN2yQsTDDvbcC6C7CoChvt3D8EsbYnNKwz0+TgDOJvVzaUc0cUgy9d3/SVfJCM=
X-Received: by 2002:a81:5c0a:: with SMTP id q10mr3990074ywb.474.1565127842511;
 Tue, 06 Aug 2019 14:44:02 -0700 (PDT)
MIME-Version: 1.0
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com> <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org> <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
In-Reply-To: <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
From: James Courtier-Dutton <james.dutton@gmail.com>
Date: Tue, 6 Aug 2019 22:43:25 +0100
Message-ID: <CAAMvbhEPcOw_kOVANSTUwPbNe2ebGL65ZEtyqdFhnwNMZ=NuVw@mail.gmail.com>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Suren Baghdasaryan <surenb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, 
	"Artem S. Tashkinov" <aros@gmx.com>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Aug 2019 at 02:09, Suren Baghdasaryan <surenb@google.com> wrote:
>
> 80% of the last 10 seconds spent in full stall would definitely be a
> problem. If the system was already low on memory (which it probably
> is, or we would not be reclaiming so hard and registering such a big
> stall) then oom-killer would probably kill something before 8 seconds
> are passed.

There are other things to consider also.
I can reproduce these types of symptoms and memory pressure is 100%
NOT the cause. (top showing 4GB of a 16GB system in use)
The cause as I see it is disk pressure and the lack of multiple queues
for disk IO requests.
For example, one process can hog 100% of the disk, without other
applications even being able to write just one sector.
We need a way for the linux kernel to better multiplex access to the
disk. Adding QOS, allowing interactive processes to interrupt long
background disk IO tasks.
If we could balance disk access across each active process, the user,
on their desktop, would think the system was more responsive.

Kind Regards

James

