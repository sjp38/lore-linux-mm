Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1FBEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 09:40:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A9892175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 09:40:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UbmkUVhQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A9892175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3DEA6B0003; Wed, 20 Mar 2019 05:40:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DED786B0006; Wed, 20 Mar 2019 05:40:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDB7E6B0007; Wed, 20 Mar 2019 05:40:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6CDA6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 05:40:12 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id e63so1745749ita.1
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:40:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OiJTbM/+OvQR660JbWl6+zVuyfxyoOgolYDHrTppv9o=;
        b=qsYc5D5Gx31VkRRmnafEKf+Yfs/liUDDW7hqnejpcaQVcegrrxrDGSs/MbAYzGqkOC
         JBsNCqBGnhMfl5a6FfDfpYEmBlXKoJkpAgK8esWjM24fxUO7gUKyeGxe//X+8/yn72xY
         rJdqeXtO5ucW6niwsnthNelsnIcDu5h3ondLOszLyISuIMi3UuxPGv68bMLtlKr7HAmN
         mQqrg2jNI9WX2tzlxB4YqvRNcAOMoKteGXFwKxg17AuQi3g44rh+pTHUGb8hyJb2uaZz
         ptthJwffpZYKJktB4VDHk+hnL63FQJViV8RLhNqftLvsHJqaFXokoZBoLMYCOSndK/9O
         IotQ==
X-Gm-Message-State: APjAAAUeMLZZkjWBIk885PGanydJmkW8fDQM9uIF7uRnA48eHa2D9jI2
	k+G9gzAUnYBnq/+17t977RJPypMPDQq444fGOxwr1QOK68DVMdeSSjDPaD0bKP9bfDQkPYnmy6Q
	49RauEa4R+99m4NJkMSqkbVRA6vhectGT/7nOY1xSVDI1lb+Yd3NEADksV7Gybw4qYg==
X-Received: by 2002:a24:5382:: with SMTP id n124mr4191956itb.4.1553074812318;
        Wed, 20 Mar 2019 02:40:12 -0700 (PDT)
X-Received: by 2002:a24:5382:: with SMTP id n124mr4191927itb.4.1553074811591;
        Wed, 20 Mar 2019 02:40:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553074811; cv=none;
        d=google.com; s=arc-20160816;
        b=YJUXZdj5NtxhhLHz3gT3YAu+HENK9ZprjF4nUqwXzAIIcgOfhiq4q/KeRM90UYuacr
         G+EPS0hhEhsbsFZPFA200Q88pWzNamWXv3X5f6LYE5cXFRGw4VvvfM6u0B3EtZC7Qutd
         /4WKZQfqVHcSjNcfBWJrAmgsV1UP9DdsvRxKWm8d1wjx84aihe3OY3XzMLKBBQh9ybre
         iHut0SlF/Ch/x1WqxnUnZlCRt1kB6azWTXFSvGC9HOlc0NVkWcQ3b7LfQpwR6JE4QIqu
         4TqLKHeGQbXwI8/1miEG1Boi1cxwq0As4m2ayy7X7M1XFvszDz5tHCshqqBE+mx9KK6A
         7e+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OiJTbM/+OvQR660JbWl6+zVuyfxyoOgolYDHrTppv9o=;
        b=pdFaLMcJK+Cy6+EvSCnsQx1DiMx4Uygh9LOwCM88aO8fDt7P43L0C9/gqmJ1HAOo1b
         dT+0KM5Q9DXN979SLbsX+wdjHhigqCdY98WfsrpQwoB+DeAlz8iDmwFhb8VUlh6FUe/N
         aOEny5iBdpMGmXjT+7u/qsWmMz3DgK3AJHv/ylQQAK79ZiR/4TBUGf9jCriwGPxnRUpJ
         JoVuERvlXwy17G5XLoiTNSqPjFnJoXh5Zos9ZgegwxrtkVCTNv+G8JkAhfSAFqqbYa/C
         1SFGgbIe/VlVOvhugFFxnd5G25LYtwA+x3KhR7KH5eYDDloNaIUDdFHnGLPLt4K0F9+u
         Ny9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UbmkUVhQ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c3sor2812535ita.15.2019.03.20.02.40.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 02:40:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UbmkUVhQ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OiJTbM/+OvQR660JbWl6+zVuyfxyoOgolYDHrTppv9o=;
        b=UbmkUVhQ6gqRKw15CYlRVu/W4JQgjq0CvncfH5C4DWuhC3EqeR0RaRxF5yfkGexfa1
         Mht8+edc7MKM8X+UomJlChY9JyDYqK0gn50DGg4XkRREhhKYShGssew6ccaX74Z2Q6ph
         EODVRAEjPF4hueSKa+rsMnG8lx7HMZ9qzr73+6uyZfbQHmLqAs6Wla5/gs0vRZSQXDLD
         wQbv5czx8u+7ltp0yCTFMU0MwH6Ft4FQMlO1apyrGGpvzmiLEFZ3f2OHAoo33tQzd5gW
         8nzBVcBNlNrCKiJ77Q9EJDOBHOyJ94rx8J1SE5DtPtnXZhZ32wTrPEbbQefiTldH8kIN
         acFA==
X-Google-Smtp-Source: APXvYqzS7Q49tQ/6IJEY6eYWMi5dAcdCwJpyJ5vkanjlZIIbSt6Hovwuy+RiHNXZtgd+VUix3Y4Z6127Wx3Hjbo7jHM=
X-Received: by 2002:a24:9a86:: with SMTP id l128mr4297591ite.12.1553074810833;
 Wed, 20 Mar 2019 02:40:10 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000f7cb53057b7ee3cb@google.com> <000000000000c7bd5c05847bfcab@google.com>
In-Reply-To: <000000000000c7bd5c05847bfcab@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 20 Mar 2019 10:39:59 +0100
Message-ID: <CACT4Y+a=9DQhgq243k9c6SPiyAhDQG5y2GqT4Da_P97t5n4Brw@mail.gmail.com>
Subject: Re: WARNING: bad usercopy in corrupted (2)
To: syzbot <syzbot+d89b30c46434c433dbf8@syzkaller.appspotmail.com>
Cc: Chris von Recklinghausen <crecklin@redhat.com>, David Miller <davem@davemloft.net>, 
	Kees Cook <keescook@chromium.org>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-net@vger.kernel.org, netdev <netdev@vger.kernel.org>, 
	Stefano Brivio <sbrivio@redhat.com>, Sabrina Dubroca <sd@queasysnail.net>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Matthew Wilcox <willy@infradead.org>, 
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 1:49 AM syzbot
<syzbot+d89b30c46434c433dbf8@syzkaller.appspotmail.com> wrote:
>
> syzbot has bisected this bug to:
>
> commit b8a51b38e4d4dec3e379d52c0fe1a66827f7cf1e
> Author: Stefano Brivio <sbrivio@redhat.com>
> Date:   Thu Nov 8 11:19:23 2018 +0000
>
>      fou, fou6: ICMP error handlers for FoU and GUE
>
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=14a57f83200000
> start commit:   b8a51b38 fou, fou6: ICMP error handlers for FoU and GUE
> git tree:       net-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=12a57f83200000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=c36a72af2123e78a
> dashboard link: https://syzkaller.appspot.com/bug?extid=d89b30c46434c433dbf8
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=170f6a47400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12e1df7b400000
>
> Reported-by: syzbot+d89b30c46434c433dbf8@syzkaller.appspotmail.com
> Fixes: b8a51b38 ("fou, fou6: ICMP error handlers for FoU and GUE")

That commit caused lots of crashes that look completely differently.
Now all that is fixed. The last crash for this bugs happened 2+ months
ago. So let's just do:

#syz fix: fou: Prevent unbounded recursion in GUE error handler also
with UDP-Lite

