Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA9E5C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 09:05:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 810D2217D9
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 09:05:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 810D2217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E2AA6B0003; Mon,  5 Aug 2019 05:05:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 195016B0005; Mon,  5 Aug 2019 05:05:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A9C96B0006; Mon,  5 Aug 2019 05:05:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5C3C6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 05:05:29 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so45901847plp.12
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 02:05:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=WQOvB0oj/Z+Ekb5jO8cRqSgPElcfg+ucGCHwdTHb9QQ=;
        b=sRedLIE4tOMe9i7YDWepUhKyDlhHLaZM58cKfRyYem39BNO6A6OnlqiXTXPXwVU9k2
         Ion0A3kekD891JbrNpXmvM/2Qvkoc+kD+YEPrvKUgKCMv/My6wAIBCMNaA/jwH60bNBr
         Omip+4HuTYYj1U1OTA4Mi8Vcw7rEDhvZpC799VkTh5hDxv++s7vHtbuAwLiZ5iwToRJH
         AqDsq0ZtEuIle8h7RQTUORs0K+pgsL0yEfASdm1mNthkHYrg1jXEAbhh0/NQn9zEyin+
         Qnf1i/DXqV+7E/Kh6K3DxoFM2V3QsP7Tei5slha//6c4Pp9Kdhb1Pe9YktQFS62duz58
         4CDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAUTDekYK4UR8DOCHPJPgqESuL2ZJYigI+vbz3F2RXJ2o9DiPBK7
	oN3lVwq/JI3MXzCrGrS3rf2yWfYtR9CH698BJACxxowUrAaE6jOzt7pQu58+etFejgX2mxR7Ekx
	RfCxJ2b/0Cm0VuwualPvgoJSbdqKPLEY2eqZkTcK0cJKIp265rlUXRlaAmGeiycKVAA==
X-Received: by 2002:a17:902:724c:: with SMTP id c12mr140826841pll.219.1564995929411;
        Mon, 05 Aug 2019 02:05:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4RrUr7zdBZgfy8aaWxWvEMfHeidMaKmFC/Qvm3VF2pTuBxPFOZU684RWSExlC40OkYC4P
X-Received: by 2002:a17:902:724c:: with SMTP id c12mr140826767pll.219.1564995928223;
        Mon, 05 Aug 2019 02:05:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564995928; cv=none;
        d=google.com; s=arc-20160816;
        b=I+dJOEzaLFWGEdMy6eE7/LG3AiCYsJ5FeLxDk1Lkic/KfljbMsuMA09e3oszNWThSm
         M3WiODgzc4O4IbogKzKNy+EAMXi6Xmg4spSfAMZoztZ/YspEExNmIyLUayGcOES2b9TB
         MWyIQ968GUkX4R5OxnNVbzU4rNuXTedg8RDm0hEKPXI4ARoGOwwdoe8FBQF1E0EBL98p
         c1jVRhiMBl2fpMAUfYn2ryPdgtrnBqMsoSvazikjg7bkqE6tmwvUfeIt7blO6A2H0/JX
         RPbcM7CQqqMbYsjZJSeaTI0JokRNg+hjb7Xptm01uF8VkY5pvoDHOaItme1PNbS7KFEO
         cM/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=WQOvB0oj/Z+Ekb5jO8cRqSgPElcfg+ucGCHwdTHb9QQ=;
        b=SE7voK4C3Upw4AY849zse5S2RujjsmRhxNDxs9zZ4WzlG9WK7PVbzrPPneIYjdMiQK
         BymahokbFI83JFrCm8oPFWZCRe/gfGwEIJxmiSnfOWcsdN8sqHkypxm+RKIAEtrY2f8V
         AATlTF5eh4YVgQZzWrmMm5E5WnRMzU+buo+gLMdoFqQ08PQA0Uf4ltTKLISVdWAJQ9AM
         LUcaeLa/cTeZjf1B7s0/Pmp2D9W7/TPa+62GzlWg8tXrIt34YMtCe5MSLTvckKYS5mP8
         V1CruNhK2dI0ojGZP7w9G+Z+dCZB0KkVwxjFXYHL4jAulQHzHFnPIWfx80weZnY75npA
         uo5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-212.sinamail.sina.com.cn (mail7-212.sinamail.sina.com.cn. [202.108.7.212])
        by mx.google.com with SMTP id c10si43834827pgw.174.2019.08.05.02.05.27
        for <linux-mm@kvack.org>;
        Mon, 05 Aug 2019 02:05:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) client-ip=202.108.7.212;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([124.64.0.239])
	by sina.com with ESMTP
	id 5D47F15400002644; Mon, 5 Aug 2019 17:05:26 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 13834250201160
From: Hillf Danton <hdanton@sina.com>
To: "Artem S. Tashkinov" <aros@gmx.com>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's inability to gracefully handle low memory pressure
Date: Mon,  5 Aug 2019 17:05:14 +0800
Message-Id: <20190805090514.5992-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000060, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 4 Aug 2019 09:23:17 +0000 "Artem S. Tashkinov" <aros@gmx.com> wrote:
> Hello,
> 
> There's this bug which has been bugging many people for many years
> already and which is reproducible in less than a few minutes under the
> latest and greatest kernel, 5.2.6. All the kernel parameters are set to
> defaults.

Thanks for report!
> 
> Steps to reproduce:
> 
> 1) Boot with mem=4G
> 2) Disable swap to make everything faster (sudo swapoff -a)
> 3) Launch a web browser, e.g. Chrome/Chromium or/and Firefox
> 4) Start opening tabs in either of them and watch your free RAM decrease

We saw another corner-case cpu hog report under memory pressure also
with swap disabled. In that report the xfs filesystem was an factor
with CONFIG_MEMCG enabled. Anything special, say like

 kernel:watchdog: BUG: soft lockup - CPU#7 stuck for 22s! [leaker1:7193]
or
 [ 3225.313209] Xorg: page allocation failure: order:4, mode:0x40dc0(GFP_KERNEL|__GFP_COMP|__GFP_ZERO), nodemask=(null),cpuset=/,mems_allowed=0

in your kernel log?
> 
> Once you hit a situation when opening a new tab requires more RAM than
> is currently available, the system will stall hard. You will barely  be
> able to move the mouse pointer. Your disk LED will be flashing
> incessantly (I'm not entirely sure why). You will not be able to run new
> applications or close currently running ones.

A cpu hog may come on top of memory hog in some scenario.
> 
> This little crisis may continue for minutes or even longer. I think
> that's not how the system should behave in this situation. I believe
> something must be done about that to avoid this stall.

Yes, Sir.
> 
> I'm almost sure some sysctl parameters could be changed to avoid this
> situation but something tells me this could be done for everyone and
> made default because some non tech-savvy users will just give up on
> Linux if they ever get in a situation like this and they won't be keen
> or even be able to Google for solutions.

I am not willing to repeat that it is hard to produce a pill for all
patients, but the info you post will help solve the crisis sooner.

Hillf

