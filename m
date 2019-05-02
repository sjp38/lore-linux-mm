Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.9 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C887CC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:20:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D19420675
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:20:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jzQVifsY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D19420675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B648B6B0003; Thu,  2 May 2019 11:20:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B159E6B0006; Thu,  2 May 2019 11:20:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A037F6B0007; Thu,  2 May 2019 11:20:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55AAA6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 11:20:22 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id j22so2727194wre.12
        for <linux-mm@kvack.org>; Thu, 02 May 2019 08:20:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5iZHfQ8GDd0Ls6ejuDG8WIo78Gj60D8gd5oYhOzj700=;
        b=o3mPoxvbVnAvLIzfMSHvES10xLsrxdVorY7JGJrJVm3cZ53w9EcbLNBGPRG8OhR4G2
         v/P8pFrRFoWdji7MPT6b3qq/4s9YUGZEp/YtRrYJSh6ZD3TGSXlgw24j22Iv5AMitcrZ
         Q+ODziDzUDO7aE0RIdfOIXRuytmTH1B6EGI/C5T37Q8YDmizW402bTavO9nnf9SsS+qt
         uR+0BNKkn4y528EK+b6RqHoVgYt3phXux8Rg+SEZGz3lmjYS62KrYhgMd6RlaFqWJYOY
         Di0uLqwOJum33iaSJTljMxStb3j2GQ2z9Xh6yXElYsjIdyjCAj+V3uCijrhPuVc7aCdo
         CAYw==
X-Gm-Message-State: APjAAAVKiUla1QzyQ2k7nDTzRZc0brow+zGaLaVQUmw0zz7jGDp+4LdE
	kwM57/+RXNrcLT8uM5etda4FNK73V0TEb3ELvOn5qX2MqWo1LzIJHfN4MUGUPjfkHmWX+Cec/My
	Pzsc/xoYKTrulSzUxEBrmIYewzI8rF9awWMtmm4UDIl75m0GMfQC1N8YbQgN0uyQ=
X-Received: by 2002:adf:e684:: with SMTP id r4mr3101506wrm.169.1556810421690;
        Thu, 02 May 2019 08:20:21 -0700 (PDT)
X-Received: by 2002:adf:e684:: with SMTP id r4mr3101452wrm.169.1556810420770;
        Thu, 02 May 2019 08:20:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556810420; cv=none;
        d=google.com; s=arc-20160816;
        b=y9noTdydtbYEpfYrs5KKtnT9NJmtDVN4DEn2Gp47RcDAQBGNVm3g7QQrI3GP6DvKU+
         bApjGBbUpf6ECNZetjrdFJKTUsFR//r0/OGBEgUuCvqS1eIyFVsb+Q2u+D5HveUoMkew
         Pj4xTxZs9U51ZPA+frg+Q5qvj9lWzrFO7AV2MTeWDiQzGzR/TXEKOwNTNiU7uWPEGYPS
         gZnXIt//EBVSE9Z0Wh6pH30vYiBq+SK3UbVpHtkiy4HFQ/D/iUwzOlwaDfS5LjPZvfb3
         xanbnDPCO6cknkzBMZL63AZvQR3quuP3X+zxoL5aeHrTUx0wZXXeyzQ3HPJTWEROEtlB
         nJig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=5iZHfQ8GDd0Ls6ejuDG8WIo78Gj60D8gd5oYhOzj700=;
        b=q5hnIIp0Kj8aUDpNiQoYibvOwk8jUs3C8ubN5n5Jk35ChYTX9zncdSzlq/HA6XLhkI
         GaQPr0JH8urTUxioYdj8jdBGsFTsQvjZ+09zwU5y2vIz4SOCjuipOegcep6nfFCEqqR2
         n7ZGOGjY9+BLKTklndXA/zlG1quYQDirffUdoEz/S+si/PeSJEMO6RABUe1MJoPuJCjE
         VGLpHIsoA9osuAp+fDScJiAaEXoLxi6cYd9t7/khQSB4s4IFEoHWM5yZYjoLM+4nKTbB
         Nfqdhsi1pqToutDKj5ncx7yNSht53l2awQKGUlHAnNKi3ZS6sod4FneXMgkbUpzKVt/y
         nX+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jzQVifsY;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p18sor4062903wmg.10.2019.05.02.08.20.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 08:20:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jzQVifsY;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=5iZHfQ8GDd0Ls6ejuDG8WIo78Gj60D8gd5oYhOzj700=;
        b=jzQVifsYy8fMTiCtgC1O/9kll4n/Bj8/l/rsGB4yIXwPIjtgnwSG+x57tTQeXNRS80
         iLyJbX0f0w+pO0yQ2b4vnHUVDTsr/BMS8rX4nhkj7Vvs35/YFozk7UL1NsM0P2RZ59iM
         Nc4dRwS4LJB1eLeikglNxQql9LvadPnzaAIaE+W55cwtiGo3evT7P/NSDExizrE/vdCK
         FqTE48KQmO+PbE0P5rVeU8k+aVroL+uQHkCFzjIW+vcda2K7R+tkGG0/AHpLdnU0Ezfj
         zjlItED5vppiw32GpvjIsHmnpXNVWabcs5oGKMrWTsggLyVmPETq7jDG+ZeynKNSVet4
         pzqg==
X-Google-Smtp-Source: APXvYqz2a88pHyfeJ1r7bzIgwGeuv5y1UhZAVXtEWIBuqYBjV11xhWa33BRF5AukmEhqJIMBc7tEnw==
X-Received: by 2002:a7b:c353:: with SMTP id l19mr2664125wmj.12.1556810420312;
        Thu, 02 May 2019 08:20:20 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id q7sm8729877wmc.11.2019.05.02.08.20.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 May 2019 08:20:19 -0700 (PDT)
Date: Thu, 2 May 2019 17:20:16 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Robert O'Callahan <robert@ocallahan.org>
Cc: Andy Lutomirski <luto@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Jonathan Adams <jwadams@google.com>,
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	X86 ML <x86@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call
 isolation
Message-ID: <20190502152016.GA51567@gmail.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
 <20190426083144.GA126896@gmail.com>
 <20190426095802.GA35515@gmail.com>
 <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
 <20190427084752.GA99668@gmail.com>
 <20190427104615.GA55518@gmail.com>
 <CAOp6jLa1Rs2xrhJ2wpWoFbJGHyB99OX9doQZc+dNqOSUMgURsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOp6jLa1Rs2xrhJ2wpWoFbJGHyB99OX9doQZc+dNqOSUMgURsw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Robert O'Callahan <robert@ocallahan.org> wrote:

> On Sat, Apr 27, 2019 at 10:46 PM Ingo Molnar <mingo@kernel.org> wrote:
> >  - A C language runtime that is a subset of current C syntax and
> >    semantics used in the kernel, and which doesn't allow access outside
> >    of existing objects and thus creates a strictly enforced separation
> >    between memory used for data, and memory used for code and control
> >    flow.
> >
> >  - This would involve, at minimum:
> >
> >     - tracking every type and object and its inherent length and valid
> >       access patterns, and never losing track of its type.
> >
> >     - being a lot more organized about initialization, i.e. no
> >       uninitialized variables/fields.
> >
> >     - being a lot more strict about type conversions and pointers in
> >       general.
> >
> >     - ... and a metric ton of other details.
> 
> Several research groups have tried to do this, and it is very
> difficult to do. In particular this was almost exactly the goal of
> C-Cured [1]. Much more recently, there's Microsoft's CheckedC [2] [3],
> which is less ambitious. Check the references of the latter for lots
> of relevant work. If anyone really pursues this they should talk
> directly to researchers who've worked on this, e.g. George Necula; you
> need to know what *didn't* work well, which is hard to glean from
> papers. (Academic publishing is broken that way.)
> 
> One problem with adopting "safe C" or Rust in the kernel is that most
> of your security mitigations (e.g. KASLR, CFI, other randomizations)
> probably need to remain in place as long as there is a significant
> amount of C in the kernel, which means the benefits from eliminating
> them will be realized very far in the future, if ever, which makes the
> whole exercise harder to justify.
> 
> Having said that, I think there's a good case to be made for writing
> kernel code in Rust, e.g. sketchy drivers. The classes of bugs
> prevented in Rust are significantly broader than your usual safe-C
> dialect (e.g. data races).
> 
> [1] https://web.eecs.umich.edu/~weimerw/p/p477-necula.pdf
> [2] https://www.microsoft.com/en-us/research/uploads/prod/2019/05/checkedc-post2019.pdf
> [3] https://github.com/Microsoft/checkedc

So what might work better is if we defined a Rust dialect that used C 
syntax. I.e. the end result would be something like the 'c2rust' or 
'citrus' projects, where code like this would be directly translatable to 
Rust:

void gz_compress(FILE * in, gzFile out)
{
	char buf[BUFLEN];
	int len;
	int err;

	for (;;) {
		len = fread(buf, 1, sizeof(buf), in);
		if (ferror(in)) {
			perror("fread");
			exit(1);
		}
		if (len == 0)
			break;
		if (gzwrite(out, buf, (unsigned)len) != len)
			error(gzerror(out, &err));
	}
	fclose(in);

	if (gzclose(out) != Z_OK)
		error("failed gzclose");
}


#[no_mangle]
pub unsafe extern "C" fn gz_compress(mut in_: *mut FILE, mut out: gzFile) {
    let mut buf: [i8; 16384];
    let mut len;
    let mut err;
    loop  {
        len = fread(buf, 1, std::mem::size_of_val(&buf), in_);
        if ferror(in_) != 0 { perror("fread"); exit(1); }
        if len == 0 { break ; }
        if gzwrite(out, buf, len as c_uint) != len {
            error(gzerror(out, &mut err));
        };
    }
    fclose(in_);
    if gzclose(out) != Z_OK { error("failed gzclose"); };
}

Example taken from:

   https://gitlab.com/citrus-rs/citrus

Does this make sense?

Thanks,

	Ingo

