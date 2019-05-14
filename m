Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2A17C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 15:43:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 572542086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 15:43:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="o4uo3BL2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 572542086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB7546B0005; Tue, 14 May 2019 11:43:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E66CB6B0006; Tue, 14 May 2019 11:43:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D55FB6B0007; Tue, 14 May 2019 11:43:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF646B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 11:43:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j36so11740392pgb.20
        for <linux-mm@kvack.org>; Tue, 14 May 2019 08:43:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=v0nvVqgy68rs5XKTL1qS0XTg9vbvJX75DMTfHz65o7k=;
        b=U52PnTlsC8BBDUqXPkoNt6G/C3snl04F9cJo4Y97tKBntA8104dhfCRRGNd8pP5R4u
         SxTU77DhtjUwPqjteBAnvs7x1DROLTeensVv3Hud+/rfDgkdTskTkMyaBPsaKVH4l4a6
         gu4r2JxZDhNyeXBQQMe8BoPBiymQ1lnQfkNavxHguyl7sWZpWCapX3nw/H/jnGvjOCMi
         HPJf3+ad6F+rovJGkpTeSVdr548BktHjpM7sC18RzcWYhFALHjHE651Q1tPm8T1oYlcp
         Kf1tbtNV2yYEJwH1U3yDL/sqFQd34hzsRa6FDNsdawcuOoiWIFeLIFpUOF1g0atJnwv3
         2MAQ==
X-Gm-Message-State: APjAAAWoUE/A/f/ULalsZHNWajs645r52ffUe21r1FafwrUAYZpamGgr
	JJwJwLd9pICgS49pLR2P6Agz/wdiJVbeQ0GmipL2eg+hR+pt8bVJnCFDNIhDssAJ0c3Xyn0sieY
	ErT3R60/fLoLuTLkHpLwLYcI+DYHpMCIpPbByMSePegZtN0f6k2IcE/QW7oiL6BgsIA==
X-Received: by 2002:a17:902:42a5:: with SMTP id h34mr16094704pld.178.1557848628048;
        Tue, 14 May 2019 08:43:48 -0700 (PDT)
X-Received: by 2002:a17:902:42a5:: with SMTP id h34mr16094638pld.178.1557848627362;
        Tue, 14 May 2019 08:43:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557848627; cv=none;
        d=google.com; s=arc-20160816;
        b=OFVBjPziHJN629itf35e1CcWHwiASq9l9FrqKQe1iqLWJ9FtatKhKsVeOJ11ilNZcE
         aRCrbxDAQrUB2d0bbbYM1gw9VkYiMpsfX0NOA6o+yRvPgCctARixJV6asdlGHIivIFVH
         OGeYZs+oTJM+FNzqwRK87SEDg3qI4cqejUC4vA+fpHhf9/5aNiuO21BKXUl5AGSsEzQL
         3Q3/eDSaAy/6YxCi5vTh+tK+/uBg8Wdq+m0uChE7Y+o2yhHKqifwGhTZJb91RUvfyJSs
         M2hROwATkngwb6zmCuLH7iUdpyiwHpYTTMQN/iGZvmJ2Y/wkDVkYP7qYziT5jgKg1dq5
         +1zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=v0nvVqgy68rs5XKTL1qS0XTg9vbvJX75DMTfHz65o7k=;
        b=i1lLUCQ4Heb/zv1W7HkB7Ex4tI4kRNJJpLH2jgdEdPqex/VJaRyi60u48FA9SYt4lR
         pkpyx96BkYJgHQNbveICTAEI5QiI9dK/pixUNp+JSFae41zgRSmFAyORfedstax5Eig9
         qXan6JRabCllgAiLSfR6zjHpgaE2sJEvfAY5M8LVuhasU3BR7C5wh2kE+phkZnBhpwZH
         5bUIdlYrM3R+Ncq0oAXv2UKvQjHfnD2uzBNfxQEGa5qDuUamBlRoydcCZ5ygowosO+QK
         OJlELmrFrJBwycVHyWwXcNo6tTQPfY8DleFgv4Jd1P0XEiFmquudp8NkFwTACbF+rSlH
         RVPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=o4uo3BL2;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12sor17202139plo.34.2019.05.14.08.43.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 08:43:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=o4uo3BL2;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=v0nvVqgy68rs5XKTL1qS0XTg9vbvJX75DMTfHz65o7k=;
        b=o4uo3BL2FJTiVqjqCYWGK7TMMV+lwcOVDCNWJTqe+tsflDaF1yLX/e9s+YSEdV9a/X
         0LABKAoi0StS36W6oGQpGj2P9Ct672agdHbaJD3SQjoZ0jW0NpD1tvHmfqZg3k3gEIMm
         pD3Y0PN2veoFVEcAjudbuFBK4ihHBhxjGmFrArDMaQOSdIoNf0wbzeoWhlxvo11h8EQj
         5+ePJDr+YQ3YkBtn6wnDJCoLAujldWH4NLM1lyC6LyWFIUDCdOPrWhUQBDcmMaKmwirX
         GLQ96LzLwwi7s2MUdjqt+joWr3rsVAX/g44QiL28zCZdC3f8nx6CKfXtYBWsA//YqsXb
         s4oA==
X-Google-Smtp-Source: APXvYqzfFBQAOq4cxgvOLcK8bcyy/NCFnT7eLClak8c7V4eglmQgE2DbsTwqSnHYj5t5cw7CJVy3Wg==
X-Received: by 2002:a17:902:4203:: with SMTP id g3mr19140823pld.288.1557848626663;
        Tue, 14 May 2019 08:43:46 -0700 (PDT)
Received: from ?IPv6:2601:646:c200:1ef2:1d0a:33b8:7824:bf6b? ([2601:646:c200:1ef2:1d0a:33b8:7824:bf6b])
        by smtp.gmail.com with ESMTPSA id o2sm36069339pgq.1.2019.05.14.08.43.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 08:43:45 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC KVM 24/27] kvm/isolation: KVM page fault handler
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16E227)
In-Reply-To: <95f462d4-37d3-f863-b7c6-2bcbb92251ec@oracle.com>
Date: Tue, 14 May 2019 08:43:44 -0700
Cc: Peter Zijlstra <peterz@infradead.org>,
 Andy Lutomirski <luto@kernel.org>, Liran Alon <liran.alon@oracle.com>,
 Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, kvm list <kvm@vger.kernel.org>,
 X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com,
 Jonathan Adams <jwadams@google.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <8DBEACE9-AB4C-4891-8522-A474CA59E325@amacapital.net>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com> <1557758315-12667-25-git-send-email-alexandre.chartre@oracle.com> <20190513151500.GY2589@hirez.programming.kicks-ass.net> <13F2FA4F-116F-40C6-9472-A1DE689FE061@oracle.com> <CALCETrUcR=3nfOtFW2qt3zaa7CnNJWJLqRY8AS9FTJVHErjhfg@mail.gmail.com> <20190514072110.GF2589@hirez.programming.kicks-ass.net> <95f462d4-37d3-f863-b7c6-2bcbb92251ec@oracle.com>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On May 14, 2019, at 8:36 AM, Alexandre Chartre <alexandre.chartre@oracle.c=
om> wrote:
>=20
>=20
>> On 5/14/19 9:21 AM, Peter Zijlstra wrote:
>>> On Mon, May 13, 2019 at 07:02:30PM -0700, Andy Lutomirski wrote:
>>> This sounds like a great use case for static_call().  PeterZ, do you
>>> suppose we could wire up static_call() with the module infrastructure
>>> to make it easy to do "static_call to such-and-such GPL module symbol
>>> if that symbol is in a loaded module, else nop"?
>> You're basically asking it to do dynamic linking. And I suppose that is
>> technically possible.
>> However, I'm really starting to think kvm (or at least these parts of it
>> that want to play these games) had better not be a module anymore.
>=20
> Maybe we can use an atomic notifier (e.g. page_fault_notifier)?
>=20
>=20

IMO that=E2=80=99s worse. I want to be able to read do_page_fault() and unde=
rstand what happens and in what order.

Having do_page_fault run with the wrong CR3 is so fundamental to its operati=
on that it needs to be very obvious what=E2=80=99s happening.=

