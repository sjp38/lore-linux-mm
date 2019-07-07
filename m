Return-Path: <SRS0=llCs=VE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1372AC48BE1
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 15:49:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1B8B20830
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 15:49:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YvbEjwwJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1B8B20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58AF38E0003; Sun,  7 Jul 2019 11:49:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 562BA8E0001; Sun,  7 Jul 2019 11:49:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 477648E0003; Sun,  7 Jul 2019 11:49:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 256E78E0001
	for <linux-mm@kvack.org>; Sun,  7 Jul 2019 11:49:49 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id u84so9059103iod.1
        for <linux-mm@kvack.org>; Sun, 07 Jul 2019 08:49:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=b4nSr8C4VJLXjo2WMEW+SSHBlpQfsTI/51+kxtK6GPA=;
        b=q7lS4baBFCwJ+oLvMqAnvjieoXnaiFZhoB08nIXqpg4R0AsiByvEErYmLdwi0WfBmH
         dQyR0gJXPPM3ZKfW8R0jDLvJXctP2D/NAZAWb/3KesLYWoH3746bkp3sj2kCD+vPaq5B
         7S4ayfqmIztUYzK0aQX9ahslU3056/ZX75mYa3y2KJH3DxDtNuwtDr5cZgy1iGokcEUc
         rRG2tzsu3wPyIVeuGyrJdOVnrHgo98f2g83jQ9jTveAwtlbfARbX/WDyu6IuBBMVWCEU
         LW6w/8/5fe/Fhbkjxej+1lQN8OEhZ3JMzq/zBObgd+s1654vVS7FxfF6LhGDnc2hQyzu
         14Eg==
X-Gm-Message-State: APjAAAUgX1lyTFCgerl+nqO2Uhef1NDxGIed2DlxAri8M8cn3DJmJn4i
	1AIn/cpyw1CHMp4S22nOOVUidZsSZx5OUOPIpMnvYeBvls06xydozwJ/5M3ndQQFyQd/GdqRxBU
	hJe56IZ93YfSErEJiDTOXsQjEvxkY7QqR+e0eR8pb1MP9hLu6AofsJyAvkpBYmazR2Q==
X-Received: by 2002:a5e:8e42:: with SMTP id r2mr13507648ioo.305.1562514588935;
        Sun, 07 Jul 2019 08:49:48 -0700 (PDT)
X-Received: by 2002:a5e:8e42:: with SMTP id r2mr13507602ioo.305.1562514587837;
        Sun, 07 Jul 2019 08:49:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562514587; cv=none;
        d=google.com; s=arc-20160816;
        b=fcmOa6E0NImHOZPHFW+EKeoJnx01iQENYeC5Pr++KSxcaXrRk7sxwaUNt8Evpx16oY
         91+7inZ7iNT972HQqelCeiu4c8HAjiC425kMhwsEKQkzgOtMgqDRvxp58iFjkLo6/8g9
         d++8xhv28iTUkZClKGnkzbThT0QV2T9pypCPhY0iGRaFl2L88DzRc3lBEtkQnicYK/yf
         AtDyPp/RxYBjIwS+I5BiVUdJTGLkIlLvnW5TDFoBUAug9mZaar/3hnXLRZTMEt5YHpiT
         QWJE3laBxmk1gWfJZFCEBhGYAS9lXL1UNrKs4n8DLWyufJpJ/wgdNFZ28R8qZ/xE3S7n
         nUxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=b4nSr8C4VJLXjo2WMEW+SSHBlpQfsTI/51+kxtK6GPA=;
        b=i7n3ciYGxMVsLHNICHkgivfLR/1RISvKUNIFwbQriZnfang7D53DSSzk5b0l6qsujB
         JVv35Mo/3DBcjLzEqusELVZIuylPaLYYZU5DfaH+cQkevlPBOyIewyHDUrgOHF/7cUh0
         pBDhcAcIUYysj0l9wh440tHltgt0McFMPmtECq0E5ubTzVj7Qu8NmXl2DVNlpPIQt1QF
         lV+WQ7tnPg0PX6JQxtI9oqa1x2V4CtZ+oSjbWbrDJTl1LbDUojlxfSrOcdAUrWzgG035
         0IoyMdNrcyeyBgv+lHXj4kwZeJSJgJwTnR9LmyPr1WHjfP1jxQ4f8vKeJFZv/T4iGZFe
         hXGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YvbEjwwJ;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j184sor10316112iof.140.2019.07.07.08.49.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Jul 2019 08:49:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YvbEjwwJ;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=b4nSr8C4VJLXjo2WMEW+SSHBlpQfsTI/51+kxtK6GPA=;
        b=YvbEjwwJ0MctJmyVW2533O+SajBFaUp96J65ETZP+TatSMINnLBybugK6AoA58+MfZ
         yd15CnKnxIQnb+432TC0RnoimNjVmfkheHmHbAo/DwijS92RSoszBySc4s83WHsLef+p
         ZXtoF5JncfYaRuocLhwSQN5OoVp+NjBZozVDL1n9KB5gbQrKGBokpNMsMHF7ScczNG9W
         VErLPBTv8kbBqF0FjQSgB5IYmd3oOKSbu8CTCDMwj97kfsW30VCistO+f40EnHTS7A1p
         IDbwYqJzeKXw/J4laVfJb/T57lFaIteuOcrYiq8sMQEpG3HKhJKB2f+Q6gR5Akx+kl5u
         1M5Q==
X-Google-Smtp-Source: APXvYqw8oS+uiF28Cm5vFb/bwzir+3/EqF2Ea/W20KGlon5E6qPXtr6B7HM849DAD8MJjXYvcZw/7BLf/kSb+cG9qi8=
X-Received: by 2002:a6b:c9d8:: with SMTP id z207mr13631851iof.184.1562514586987;
 Sun, 07 Jul 2019 08:49:46 -0700 (PDT)
MIME-Version: 1.0
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
 <1562410493-8661-7-git-send-email-s.mesoraca16@gmail.com> <20190706192852.GO17978@ZenIV.linux.org.uk>
In-Reply-To: <20190706192852.GO17978@ZenIV.linux.org.uk>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Sun, 7 Jul 2019 17:49:35 +0200
Message-ID: <CAJHCu1+JYWN7mEHprmCc+osP=K4qGA9xB3Jxg53_K4kwo4J6dA@mail.gmail.com>
Subject: Re: [PATCH v5 06/12] S.A.R.A.: WX protection
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org, Brad Spengler <spender@grsecurity.net>, 
	Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, Jann Horn <jannh@google.com>, 
	Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> On Sat, Jul 06, 2019 at 12:54:47PM +0200, Salvatore Mesoraca wrote:
>
> > +#define sara_warn_or_return(err, msg) do {           \
> > +     if ((sara_wxp_flags & SARA_WXP_VERBOSE))        \
> > +             pr_wxp(msg);                            \
> > +     if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))      \
> > +             return -err;                            \
> > +} while (0)
> > +
> > +#define sara_warn_or_goto(label, msg) do {           \
> > +     if ((sara_wxp_flags & SARA_WXP_VERBOSE))        \
> > +             pr_wxp(msg);                            \
> > +     if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))      \
> > +             goto label;                             \
> > +} while (0)
>
> No.  This kind of "style" has no place in the kernel.
>
> Don't hide control flow.  It's nasty enough to reviewers,
> but it's pure hell on anyone who strays into your code while
> chasing a bug or doing general code audit.  In effect, you
> are creating your oh-so-private C dialect and assuming that
> everyone who ever looks at your code will start with learning
> that *AND* incorporating it into their mental C parser.
> I'm sorry, but you are not that important.
>
> If it looks like a function call, a casual reader will assume
> that this is exactly what it is.  And when one is scanning
> through a function (e.g. to tell if handling of some kind
> of refcounts is correct, with twentieth grep through the
> tree having brought something in your code into the view),
> the last thing one wants is to switch between the area-specific
> C dialects.  Simply because looking at yours is sandwiched
> between digging through some crap in drivers/target/ and that
> weird thing in kernel/tracing/, hopefully staying limited
> to 20 seconds of glancing through several functions in your
> code.
>
> Don't Do That.  Really.

I understand your concerns.
The first version of SARA didn't use these macros,
they were added because I was asked[1] to do so.

I have absolutely no problems in reverting this change.
I just want to make sure that there is agreement on this matter.
Maybe Kees can clarify his stance.

Thank you for your suggestions.

[1] https://lkml.kernel.org/r/CAGXu5jJuQx2qOt_aDqDQDcqGOZ5kmr5rQ9Zjv=MRRCJ65ERfGw@mail.gmail.com

