Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FORGED_YAHOO_RCVD,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E3C2C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 07:51:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DB7920857
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 07:51:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="rESWC5p9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DB7920857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=yahoo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0D4E6B0006; Mon,  1 Apr 2019 03:51:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABCD66B0008; Mon,  1 Apr 2019 03:51:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AFF86B000A; Mon,  1 Apr 2019 03:51:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 586B86B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 03:51:35 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 42so6891457pld.8
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 00:51:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:reply-to:to:message-id
         :subject:mime-version:references;
        bh=/jK0x4jxPwJw1KEinC3EyJB3XO5hELN4A3Ws6yUDMCs=;
        b=X6lYIm0UHrqtdn6h/xQ8F/UN6HuJshYZzN8ZM9BSAqfyMMX/lSsHqu5wvsCsRWTUVB
         un1yTZanymmLaoZ1Dn1LVbfhYoYu736lwxXRvV7Guiz+n1ikgv446OoB+1mdyNZ8MrUf
         DQtEJ+1B22CfqcXKpkTC3uKbVAOb3fs39Ucykr6Zo8rDkLoHetU0ubF7/IYXbNYp31Jz
         dxBtcWWRvHOGIrDvMddCvbSC5Jqo7GcHUnnLJ94bane8opvpxudiue5CPyGN0Ms/sgEp
         AfaQvIpvZ9f0TR4/ZR05DUdCjwwjjOw258IaTBTkQe8ar+PJcjDWQJ2vwxJ0p/Bc79Zc
         EFrA==
X-Gm-Message-State: APjAAAX6lQNlOzt8QVz21qfZnVKfne8vC/HTKYaYDGKGjvb5zahf4g7H
	5PmLGDgZN803eOPqUgwiEg39uwSzvIRokJLgst/c4/9ghIPbJ4zfCm88mLnNk4mLqH0MgOUd9nf
	kfHuqgXguwQbSmqtdzTE7xKXhlmqS1S7WFymq8jHqxv4p1mM7jSAOHjq6vkV56ExM6w==
X-Received: by 2002:a62:1385:: with SMTP id 5mr60666956pft.221.1554105094986;
        Mon, 01 Apr 2019 00:51:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp+qNKXOebinAu0LM+LiL0BGsuM+pWy86aHk09wf7XESk+SkMG5ObCV8K2JQDCPGwAehe8
X-Received: by 2002:a62:1385:: with SMTP id 5mr60666905pft.221.1554105094077;
        Mon, 01 Apr 2019 00:51:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554105094; cv=none;
        d=google.com; s=arc-20160816;
        b=AOcFbMPY+8QHqVcSJoCBB/4k2LRA+4IcrVc5JdXM0harE1ZdIl3j7cFQ/dIo7oXcQh
         +5dsmJX3LMKp6mrYhHbntrdJXQ1RxtAuYoC+gUZiO2g/owVMLDJah6OI9x49Cocs5iF4
         5sHKarjJloqCLvdvBVwqIjiJp4A6yNntcMqpb61oeNJ5Uh+5lseshiRzTO2mA/gCc/fQ
         eH6BR9sdB9cx6bxpcj8AjcJZndFJaNO6U7K3wbsWJnA7Homo4zrUUbjeD2vKxhUrSPi6
         EfI7z7JLeKPp1Rplj8pEHzuaAuLqc55B7NolMx3sfBxYoclbP7MlVO3HcRsizwXg8eZ2
         fOjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:mime-version:subject:message-id:to:reply-to:from:date
         :dkim-signature;
        bh=/jK0x4jxPwJw1KEinC3EyJB3XO5hELN4A3Ws6yUDMCs=;
        b=L7jxkYBUezCG80KfpA9wq3c1zWqmd01Ed9Z+Uy92yV8r01ImT3gHWiXZJSv3iOeKuP
         FNeDeMTRaDSbhO6iutSXxaCKGT7YYweQWTIVAsc/SI/3UNc7B8mqcU8fVxfURaLGAjXo
         aOQV9s2jzMWZhiFFAKCH8GeSE19amB7hrvVQr7KbZdU3nJ/2DXVd3S0R+fS3bhG0tV5w
         f64i2OG80n6ta8S60gmM7SqG7AXQiQDCPsEK//ZybfZkrIlbMN8hibCGkda+7YC76R/N
         I1kchC5ec/wmmZKGqqE5FCO5jSW9eXiWFVM2argnBDbEWX0Re6d6ElQevhcDjM6QX5zC
         vKIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yahoo.com header.s=s2048 header.b=rESWC5p9;
       spf=pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.242.82 as permitted sender) smtp.mailfrom=suryawanshipankaj@yahoo.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.com
Received: from sonic301-19.consmr.mail.sg3.yahoo.com (sonic301-19.consmr.mail.sg3.yahoo.com. [106.10.242.82])
        by mx.google.com with ESMTPS id i195si8346828pgd.521.2019.04.01.00.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 00:51:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.242.82 as permitted sender) client-ip=106.10.242.82;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yahoo.com header.s=s2048 header.b=rESWC5p9;
       spf=pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.242.82 as permitted sender) smtp.mailfrom=suryawanshipankaj@yahoo.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1554105092; bh=/jK0x4jxPwJw1KEinC3EyJB3XO5hELN4A3Ws6yUDMCs=; h=Date:From:Reply-To:To:Subject:References:From:Subject; b=rESWC5p9KIlvBvrMAw5VtUkAUiigSy6GaKTJZX+QxQt3cWq/HRCew5+c1LsZE9A9e5ombIiRpYGsttrhOXRKD+qCRadTD7B89raR4WOzE+yqJH+qJFg9n5m+WkUEXgEPY0TfnDhSe4MwhZTcq9XpUCD8vHQPRAAA8Z+qRnDdGkMhNa1KiA1CtYEB+zMfTHW1K14Vn6n+sn6fX1AH/WOqHji3z4Kh3q9FoSLCpY/d2mypXnq2rcrBZQPgjCCcDupkckmt7UZDvpv/X6yyClZNoEwJGrlqiA3EwwtihEBvEwYFNf6VUtl5AgJL1FALiLW0ezDaeiVfQ7D4gEfdq9RARA==
X-YMail-OSG: tUCXzqwVM1kJyW8.4R3pZLGgcWB_yg10nYX_0D4NSeu23BPgVvlrgRFRFZ4JbCM
 _XOBUWjXprhJ2WzF7YaMCSEY.IupOM1.wRJh60TZDopkMr4XmHRS7_Fm8Md5IDcJmZc2hpy67a9a
 am0MgnM4W60OFFGKdcSrci3C6QgCaZruJe2drcP1CbInw7p.PIp3F8vhZ9ICz0jAdbXnvd0z6Gfb
 bovfEonrAFlqe3hvthhPki8h10GGFMZH_H9BlRPehPkmtrV2cvOPPJhpRg4hQ2w5Op1w1GouGChW
 GHoeqyys0iU3RA5te0CCtz5VOVsEIaRi27DLQdsogzSPGhMR63kX0pz9hNGfR3TFeT14jcL3Owt1
 pmqmQh9YodBG3bV5HYmq9EAjbQ8g55zxq4ICSwNZjxJOMWBgCcFmZFp1Wg3cf6Od6tNaeHH_ZQoh
 l2dmwd7QPJ85svHmvxa9oztFhGG6ZEDPHs_S55W7sFszBY_LhN43cJQ08_YgT9wQviZ1uy_tZ5UT
 oSCpBPkj4YsNlljOwd6VqmloAl1d3uGGWHxHOigZsR.EDubtSwrMMlWb6C0cHWyFyi6R7jLaqdeP
 N4h67oEGbwTxJkVYYfB0kMg9H6cNizZDupToef9jdsqaxGT5GfUPu91LljzTvtuj35T_imwu96BL
 tfG_ZrTAdXVD4DGCYl0r7Tr0fJ4U_vppSOLrTjBYVf68X5EcSE2XLiXv8skH8GZtMANmi79bj.p_
 JnVYPsUXBn8pKEZjETMW6ir1bG5tNR_TzjQNg66z9r9ZVEWmGAa3nqTFz2yAf5.4y.c2SR1vbsvu
 DeNOY1YTtw_9.2WgiQqYLO6C_vmpavGxb5KcolHfhtsP13yvJykr_qxMjF2A426NAOjgws3v3eIX
 0.UAnumT4SUVZnU.NRQLIpEjKfsnGnrjwMml6opm.zvU7a93FwFOU_ZeV.ueOrmucVq1T879xhny
 bJ.l_WEJNH2yT_qoXbULq1LKPMEp35yup._mUGl1zTRH36EiB4XHdcGZg2dRVGlgiXQZ2S.D_c7d
 QVb8P0avfXmMmXmg7r3Y.PKOcu3fMCY1rq98fHskAL35vXrXHlrWKEw--
Received: from sonic.gate.mail.ne1.yahoo.com by sonic301.consmr.mail.sg3.yahoo.com with HTTP; Mon, 1 Apr 2019 07:51:32 +0000
Date: Mon, 1 Apr 2019 07:51:29 +0000 (UTC)
From: Pankaj Suryawanshi <suryawanshipankaj@yahoo.com>
Reply-To: Pankaj Suryawanshi <suryawanshipankaj@yahoo.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Message-ID: <1733073807.13478305.1554105089959@mail.yahoo.com>
Subject: CMA area pages Information
MIME-Version: 1.0
Content-Type: multipart/alternative; 
	boundary="----=_Part_13478304_1097488253.1554105089957"
References: <1733073807.13478305.1554105089959.ref@mail.yahoo.com>
X-Mailer: WebService/1.1.13212 YahooMailNeo Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.009123, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

------=_Part_13478304_1097488253.1554105089957
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hello,
Is there any way to get cma area pages/memory information?
Regards,Pankaj

------=_Part_13478304_1097488253.1554105089957
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit

<html><head></head><body><div style="color:#000; background-color:#fff; font-family:times new roman, new york, times, serif;font-size:16px"><div id="yui_3_16_0_ym19_1_1554104723106_3252">Hello,</div><div id="yui_3_16_0_ym19_1_1554104723106_6225"><br></div><div id="yui_3_16_0_ym19_1_1554104723106_6224">Is there any way to get cma area pages/memory information?</div><div id="yui_3_16_0_ym19_1_1554104723106_3278"><br></div><div id="yui_3_16_0_ym19_1_1554104723106_3279">Regards,</div><div id="yui_3_16_0_ym19_1_1554104723106_8056">Pankaj<br></div></div></body></html>
------=_Part_13478304_1097488253.1554105089957--

