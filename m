Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54331C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 14:36:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0354B2186A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 14:36:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tIlWHx60"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0354B2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17AB68E00C5; Wed,  6 Feb 2019 09:36:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12A028E00C1; Wed,  6 Feb 2019 09:36:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 018F48E00C5; Wed,  6 Feb 2019 09:36:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B6A038E00C1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 09:36:29 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id q20so5036038pls.4
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 06:36:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HQHBL4H4E6t1GSVT+e5d2e8jbqm9+4cul5BGqspsN2I=;
        b=OhbGdmVfNpAMcrWVw1H1nq7MZ4+BTbwAGW6IREMDDJbpekqejtc/m2GfQ4rmQv4LXT
         dziT5/RHmcGizQ6PI+3yF9oOOQZDfrHsrHylIaNHrF8Gt0vrX1hIuCZTnWHOAEkMMrn0
         5j4aTB11FEl7z7bZZNjVemWC2qpeUsmSSYoDk7zBXY5FIzsaf+4nobmgYMN8WKn4L+eI
         FRhICUTl9MHxwC50DeXH+i7IQG96R7BdV4k/cbKqn+pVAkO1SYkqmQDfyJoor9WHGSl8
         VQYPAKsYQzLH6Q8r2pFPdSthXXiep3ANMBOAHXwUFE4eDuvOuhVsnKF+FeOSUTFcqvgV
         3pLg==
X-Gm-Message-State: AHQUAuannHIwp6G8HeZLxl7o7u2Z2LEWOVji2WiF7xFJEi4/+MDIUEtW
	c/BLafeGGxyRj8oHNCGUUdi+C7RD+ar6KxStnxgh9xgpD5LQzSI3J7gqgJz7QHmtoEyks+ofmPz
	7CfbShTyZfnWl910VhkLNTygbOJiwOwBlK13ioXkS4LkJPJVYvYINvcvTtKxSAO8PTlNm4jvZFy
	OpnCnbNqYr3Sf7fu+02m7lbqdIJcaDah6HtAhbUPwPulTa4VmECMas/IG/SG/fJrz+wSur8el+y
	9yzkeml839+r4/rVbQLzx+LCRJc8bSQpjts2oJRfrbwH1MrGOdcIxTARTXNV7k+TVR6EYxkDRZj
	aOTiVWwiv+JMsNYoh0iPYzn0HjsFE/YR0ApZ797cn69m0UYNmimR2WekV6nJdAllFJjMMDUV4A=
	=
X-Received: by 2002:a62:5c1:: with SMTP id 184mr10722978pff.165.1549463789317;
        Wed, 06 Feb 2019 06:36:29 -0800 (PST)
X-Received: by 2002:a62:5c1:: with SMTP id 184mr10722911pff.165.1549463788306;
        Wed, 06 Feb 2019 06:36:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549463788; cv=none;
        d=google.com; s=arc-20160816;
        b=Jx14XwT9uZYuwlJnZKw6//HMTf3QfzYnKEfEJyXBdheqgeYa5bf1H0OAms23eKelzT
         p+PXbMJd4/7EJU/1J2A3COepUox49+dFYY/lWK8+TKoAb/BVaYRwy0h4E8vTX8yHqK0f
         hOrcvZ8pUIdE6oZnnD5xtzCvNNRtwffm8sHL7/xdv64v8R8jmWl5cgHYAQNnuiD4Az8D
         BKccRhFRgwO/lnCSMJGcrz8ZuU/JALzrQfpheZ2+j6x34rNhln3ekOH6bgvDoMpU3UPt
         DM8IxVgMaOROGnIMEEvJc7LO32eSClo45HuwBVTlLvMWpPlRpbJnXOKw+cKblcq8urnL
         p+Hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=HQHBL4H4E6t1GSVT+e5d2e8jbqm9+4cul5BGqspsN2I=;
        b=hCW2c2RjjFD2ljCdubprmRK6EB/lCdS3/56utGcgDf7E30fELfaZ6XCuomYy/NayVs
         DfT1FqyRrFQazJvaZpdf9/8F6tojgavHFY5DIKs6AM9PdN4+1H436qprbyFkGscajK50
         ava0pGseLIHVVcIWv3ExHjrIFVNVshOuJLK1KTX7PxOhLH6aeypOSjF15uHzZeSi1LLn
         jYCYJpaqOSOEnZ7OV6DMGu/T4H+HzGX1ND2oKr5QCxLraXUyf+SQSJReN34oKdYXF7RW
         0f1YLCXHFdGYJkwcic16bmr7FEbPdsq7p8RmDQdfBw5SX1PW2FUfieXC4bDpo4V7P0lz
         wmmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tIlWHx60;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l71sor10237304pfi.24.2019.02.06.06.36.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 06:36:28 -0800 (PST)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tIlWHx60;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HQHBL4H4E6t1GSVT+e5d2e8jbqm9+4cul5BGqspsN2I=;
        b=tIlWHx60gPrDUm/8WuRcYjBTZtZaZ3gI8BSG6RAbleszT4dI53TmC5ig59sVBeJwVe
         ildDd5nrv1sQJnZjmSwlubTOCobIj0SIs4JbrlY21ixeBIlgatL0jBB9ijg9EWPXmhm1
         5s5pdp0RKzQSfQ1KID5JEUB8NG7kK9dSGtvRleYjZ27wzNDecjBZXmImM6wbzRfR50Px
         +yUqmLiiHGZ0zWfgNibVQBbGYYE/J5lQ4hO2qTPfPS1NkzcOeYwKIbVa2XQS/sM6INuA
         WuXpfy+dhdnFrDhE6Y0+owBA0W08jfIpo0YJyUwGknSd0qMT3cZ8+wQzkblyOvVM64Z9
         pKmg==
X-Google-Smtp-Source: AHgI3IY2mYr+reflHTmYh/rjy9Lup9mpYSVj1qMKfyhuqdXZ3N4QKb0xnCQ/eaqzIaVE3Vq9WBu60w==
X-Received: by 2002:a62:c505:: with SMTP id j5mr10781039pfg.149.1549463787859;
        Wed, 06 Feb 2019 06:36:27 -0800 (PST)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id n73sm9278491pfj.148.2019.02.06.06.36.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 06:36:26 -0800 (PST)
Date: Wed, 6 Feb 2019 06:36:25 -0800
From: Guenter Roeck <linux@roeck-us.net>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Chris Metcalf <chris.d.metcalf@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>, linux-mm <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>
Subject: Re: linux-next: tracebacks in workqueue.c/__flush_work()
Message-ID: <20190206143625.GA25998@roeck-us.net>
References: <72e7d782-85f2-b499-8614-9e3498106569@i-love.sakura.ne.jp>
 <87munc306z.fsf@rustcorp.com.au>
 <201902060631.x166V9J8014750@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201902060631.x166V9J8014750@www262.sakura.ne.jp>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 03:31:09PM +0900, Tetsuo Handa wrote:
> (Adding linux-arch ML.)
> 
> Rusty Russell wrote:
> > Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> writes:
> > > (Adding Chris Metcalf and Rusty Russell.)
> > >
> > > If NR_CPUS == 1 due to CONFIG_SMP=n, for_each_cpu(cpu, &has_work) loop does not
> > > evaluate "struct cpumask has_work" modified by cpumask_set_cpu(cpu, &has_work) at
> > > previous for_each_online_cpu() loop. Guenter Roeck found a problem among three
> > > commits listed below.
> > >
> > >   Commit 5fbc461636c32efd ("mm: make lru_add_drain_all() selective")
> > >   expects that has_work is evaluated by for_each_cpu().
> > >
> > >   Commit 2d3854a37e8b767a ("cpumask: introduce new API, without changing anything")
> > >   assumes that for_each_cpu() does not need to evaluate has_work.
> > >
> > >   Commit 4d43d395fed12463 ("workqueue: Try to catch flush_work() without INIT_WORK().")
> > >   expects that has_work is evaluated by for_each_cpu().
> > >
> > > What should we do? Do we explicitly evaluate has_work if NR_CPUS == 1 ?
> > 
> > No, fix the API to be least-surprise.  Fix 2d3854a37e8b767a too.
> > 
> > Doing anything else would be horrible, IMHO.
> > 
> 
> Fixing 2d3854a37e8b767a might involve subtle changes. If we do
> 

Why not fix the macros ?

#define for_each_cpu(cpu, mask)                 \
        for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask)

does not really make sense since it does not evaluate mask.

#define for_each_cpu(cpu, mask)                 \
        for ((cpu) = 0; (cpu) < 1 && cpumask_test_cpu((cpu), (mask)); (cpu)++)

or something similar might do it.

Guenter

