Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B284DC282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:39:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7800520844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:39:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7800520844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BDE08E0003; Tue, 29 Jan 2019 12:39:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16ED18E0001; Tue, 29 Jan 2019 12:39:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 035FC8E0003; Tue, 29 Jan 2019 12:39:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B5C8C8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:39:01 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 75so17401025pfq.8
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:39:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TXJAUi+KnRO5ZxXgOZUgaG6AHkHrwM3JoyLLMvo7QNM=;
        b=MR7kIZX4eyZaLh1iPTtTV2LCZ0XtEZWEzR8jrpFdRfJKaMZog6Yrx0gYyjcvvUvGvX
         yNmDK0GU9Se6guYRZkcD7Br00wAK1TWTFH/WzC957X4FALe6GITRsyWhnikBFu0M9FEP
         rYouoD6KTP54FpJ06st8s/oViSeM5KSXxWFKXwKUqZGT3t3kC50R9kJKP28El3yrpZrH
         /614MnSdumk9nU2cJT0YXwodNwN6yMCRqLTQmQAGkEV+24sy0PamsmpqQqW5hq4CEaOv
         E7odHIkZx1oCZGf1gLdpAUnNOq830BTr/WoEBh64ItTiw1mNxJ1Ju6YM/GLhuPrEqGps
         0TpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukdJ354pjFaEZkXfOE3Tbzv1xrmsdtwtyI0XxWWNnWkpUDW0sRok
	HHH9mJhMrKA/IOQ3Q+S7r1PMPYewhCOuMfsO91MCN4npkfXJamzrg7Qq17MZBMIHhp5BXQtssUt
	wMwmjw2pBZhsKfESJGLCuArGjWjtWefUBFDtHJxpo3tN8ugmj7XOWVBMAxJwiAiJ/bw==
X-Received: by 2002:a63:ea15:: with SMTP id c21mr23245950pgi.361.1548783541405;
        Tue, 29 Jan 2019 09:39:01 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7E+TNpIlHXGArhiBIbvqs3LxDBW/AkUujiXvQFkJNMSnPblOZlhNiIS/SFx7nUchd2kpJ9
X-Received: by 2002:a63:ea15:: with SMTP id c21mr23245907pgi.361.1548783540391;
        Tue, 29 Jan 2019 09:39:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548783540; cv=none;
        d=google.com; s=arc-20160816;
        b=ZIoGOpYNSgK9Tll28EhFbMDsuFdvD+8tzwJvpvJpWE7ZSXYTcDLLexTNbtyMntjMva
         f9UGBAN569h21I8jBp//Hee7zLtLwiRbdQZAc93hbTBLcjEWRpzHeqsjtTgGifk/CTMD
         GW//ZdGIOjYt0dz7tdhlauS/JaHMu941CKePzpswdxSClOHZRpHs8Dm31CY9JR0S1WF3
         S0v/YRtHtnwI1UZwzxpomCc1IwrVa619CQ6gaGw+i33DglEpgH+QhuhYCO6p0Tz68G/4
         C0ZpW97VIL4AQDKUiVUUUSOk33tYTa/bYoHEJs2TngNK9AFte8XY2xNVea/NYMcYvwda
         7N+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=TXJAUi+KnRO5ZxXgOZUgaG6AHkHrwM3JoyLLMvo7QNM=;
        b=SQn9er9Ej1rJ4U4lSAbTQW6RVSIO2WR+QWb6gZH/SATBvYasSlvoU7k+U+KVgKyAjI
         R6R7T1JsnMAF2+sLpqzWnRNrVqMuV5E7IlWQMb/Zn0uyexu6Jp95KgwqHl5U1Ud3kG7I
         NYtBcxIhscbntACghEA3H3STzP2fm/CK5hn/AW+9n/Sop3g3oSNnu0DJTNb9RvlA2h5C
         sk43T7/icrZn6zaB/r1md08vnfZXCjtQq8RvFvgr592yDT34FifEVH7RO+oLdFChZlrZ
         1BpFeMpiJgrEK6oqftmHx/kupPTTwMHJntjjTLuRxWvOPd5VdAMn4qF+srPsslL5WvpZ
         IIPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 7si4682330pfb.226.2019.01.29.09.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 09:39:00 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id B78AD30FA;
	Tue, 29 Jan 2019 17:38:59 +0000 (UTC)
Date: Tue, 29 Jan 2019 09:38:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, ben@communityfibre.ca, kirill@shutemov.name,
 mgorman@suse.de, mhocko@kernel.org, riel@surriel.com
Subject: Re: linux-mm for lore.kernel.org
Message-Id: <20190129093858.826292029a1330beb89deed1@linux-foundation.org>
In-Reply-To: <20190129155128.kos4hp7rnqdg2csc@ca-dmjordan1.us.oracle.com>
References: <20190129155128.kos4hp7rnqdg2csc@ca-dmjordan1.us.oracle.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2019 10:51:28 -0500 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> Hi,
> 
> I'm working on adding linux-mm to lore.kernel.org, as previously discussed
> here[1], and seem to have a mostly complete archive, starting from the
> beginning in November '97.  My sources so far are the list admin's files
> (thanks Ben and Rik), gmane, and my own inbox.
> 
> However, with disk corruption and downtime, it'd be great if people could pitch
> in with what they have to ensure nothing is missing.  lore.kernel.org has been
> archiving linux-mm since December 2018, so only messages before that date are
> needed.
> 
> Instructions for contributing are here:
> 
>   https://korg.wiki.kernel.org/userdoc/lore
> 
> These are the message ids captured so far:
> 
>   https://drive.google.com/file/d/1JdpS0X1P-r0sSDg2wE1IIzrAFNN8epIE/view?usp=sharing
> 
> This uncompressed file may be passed to the -k switch of the tool in the
> instructions to filter out what's already been collected.
> 
> Please tar up and xz -9 any resulting directories of mbox files and send them
> to me (via sharing link if > 1M) by Feb 12, when I plan to submit the archive.
> 
> Suggestions for other sources also welcome.

I appear to have everything going back to Feb 2001.  But I am
fearsomely lazy.  I can upload the per-year mboxes to ozlabs.org?

