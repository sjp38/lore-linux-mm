Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2BB2C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 15:30:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0BC420830
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 15:30:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.ca header.i=@yahoo.ca header.b="d37q/mmC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0BC420830
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=yahoo.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 313A36B0005; Sun, 24 Mar 2019 11:30:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C0B16B0006; Sun, 24 Mar 2019 11:30:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13CAC6B0007; Sun, 24 Mar 2019 11:30:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A73546B0005
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 11:30:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p5so2852565edh.2
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 08:30:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :mime-version:user-agent:message-id:content-transfer-encoding;
        bh=3BTYe0wlCfoSo0zemgqZ21aETVAIwEHFHMSEn5+F3PY=;
        b=gII7KtnquF9vdVtNGDSs3xs1KlCWaoQQHR8rQ0N10jYLjLweT5Q923fV0QNkP/4ILb
         KFSssONch2rNqJubwE+WzOaVVRbwDnbrXKAP6b4ZlWubvtktl37erFNluTO3gMyThCtk
         ln8dGn4dTUk5Iu4Bq7EHtHU0AghghitmRjDwGY2dbli6tbyo+LamZxFoAEjoErUKU3Tw
         Ylk33dBEFp3keErf/VTdM5XWO+jKTVL4ydUgYJ837KN1OaGaNGiOXC6RhN96jJdfYXHM
         nc0gvnRYPQUAogTUb6anOvjfu/6EXzWKfyy3VzObUfL2+mjBNEYfku0ysFA0ACCmjdhf
         d2Hg==
X-Gm-Message-State: APjAAAXXUdVLulqIn6mrddyR48ZO7DrVRXkm4D+6LFkQctCABSDtVxf3
	X9Ix6/uvHvVQeIOlVaIZ2GjkjajvqzFD3N91K74LuGJIWTLqJgJbdfXMu13MsSPrdzlV4wpzu5q
	TSS1eCIdiC3VoIRmeHIlEIJrmH3sfpQqnuBrdz8gWPLl0lDMjUqiMiN22efiropakEQ==
X-Received: by 2002:a17:906:1ed7:: with SMTP id m23mr2196483ejj.198.1553441449047;
        Sun, 24 Mar 2019 08:30:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5krUDbR5KABDRG8bbVDjYRCNuW7JpuIDzbvUv0p8cAMmf4igNkl0LFnToCBElrrxPGtEl
X-Received: by 2002:a17:906:1ed7:: with SMTP id m23mr2196450ejj.198.1553441448043;
        Sun, 24 Mar 2019 08:30:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553441448; cv=none;
        d=google.com; s=arc-20160816;
        b=zHlWQdr9tRoWPDMNTdWlZ9/UJZDwzEquQMCA7Jq34IUTriakJF6YbHTB46FZi44kXz
         W/x6ZyOBsoXiKo7aSXymMo3z5U/212FdXzrje8awMTi1PZhSS7C43mZrnmKkO1W3JXAK
         6zlohjNZBLorcIKEgeJS3T79T3VI76Smv62UjpkEVMafkrEPdGF6gDGxZ6aXdJVnRPnY
         BAIKhhkDv7PCeiCX3bSYNXFNcBSXDuhFJVKcIt7Qhz4L6Q693E0fIFULWcZam+ks7YSB
         G2/7nTTUWD3PzKIi4WCwAWj9TCrOCziKGiTS7Qfy2HrOyfsdpx8nbksIVB4f7xBmvLrv
         /Cow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version:cc:to
         :subject:from:date:dkim-signature;
        bh=3BTYe0wlCfoSo0zemgqZ21aETVAIwEHFHMSEn5+F3PY=;
        b=FApLzQj9zm9EZdNXASWs566Kzaf6h9OZ5M/OM6U8UAG3M+lTlsZAU48gxhcl87OUOI
         o36aMv7X8x0G1UUTIGFSUFssECtwmWK+BfOkyBpB48dbrxNvnVn7Wvf8dw5zetvkit2C
         DH6ggdd3+V2X06Zo/2yq5+CEusmKKaHqIOZKK4IPgJ+sCuJ1MNUU9GP3RrhMpMtsizUE
         wIERLppDhQGYCfHxibww2h8UfMGl5NATH+xesgYxb09p5C7DyD1tk/n2vFBOBflBoDkw
         n5D7F/kXIpweYFLOLM6CdNPGrekP2hs60s+5kzGP9fN3goM9qZbhbo7aDn0yQ0WrF/CC
         48oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yahoo.ca header.s=s2048 header.b="d37q/mmC";
       spf=pass (google.com: domain of alex_y_xu@yahoo.ca designates 77.238.176.163 as permitted sender) smtp.mailfrom=alex_y_xu@yahoo.ca;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.ca
Received: from sonic311-31.consmr.mail.ir2.yahoo.com (sonic311-31.consmr.mail.ir2.yahoo.com. [77.238.176.163])
        by mx.google.com with ESMTPS id a51si1699585edc.78.2019.03.24.08.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Mar 2019 08:30:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of alex_y_xu@yahoo.ca designates 77.238.176.163 as permitted sender) client-ip=77.238.176.163;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yahoo.ca header.s=s2048 header.b="d37q/mmC";
       spf=pass (google.com: domain of alex_y_xu@yahoo.ca designates 77.238.176.163 as permitted sender) smtp.mailfrom=alex_y_xu@yahoo.ca;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.ca; s=s2048; t=1553441447; bh=3BTYe0wlCfoSo0zemgqZ21aETVAIwEHFHMSEn5+F3PY=; h=Date:From:Subject:To:Cc:From:Subject; b=d37q/mmCvQ+D03plP/UT+JItgRXOWUMbU5wbl3jkkNV7hKuIsSj/JI4qNqY2bvNf6dInLagN3IX1c5diDKtmepcZcPO3I1m1Ltjfdp5Q/oWBpcJ4X9KeyKTo8u6yqES5wHxEVZaAbvDp6TZFNQT7osakBGrU7T38RuMDXulWuANFNfUYv4MZAB00LRj81rCojU8lH4gp4xA/7RsY8mw919F1/+6TwRFLNoWzWiC90XbP7CBrafRQomGgjI6GZ7DFH+2w0g6nB8U33KU4NZrGyq+nBK2AX9TmTYr0cW387dK3/L35tZg+wp4uGXprCXnOojhqv2jgZ5LiXuczEfQefQ==
X-YMail-OSG: N1cUSN0VM1nWUTKN1bMA6WwcgY45tKGfO5E38VeCuUkdAvKH.GmxcWOCh8Ca0lT
 M3pzkKWCjDLaJDDiprTDzOROt6bPQt4yCsVDvhv4nCgMTM5wgeNGRfpTeNwIIMt4iL23xbR5_28N
 Y6mAyGcUSvlokGjZSqpL.LifPaU0fVtcTCi8CIZMF0ZzwmWNTD.WuAbqu7GxUNy.5x2qZ6zYQRE_
 MZngeccpE9yePcwG4T13PbPjW3.SocMBsLM8muUW1qkIS65w4Lwq1HOtfzWbKSQiP_Fb.y1IWq7b
 mkwMnaoAk9Aconja5KKRvD4cLwp3H1Ex_xsE4fmvRvmRZiYD0qaEWJnV1KXLBdSKmL0F6.Ll7dAz
 3KWpQbnXCc_gh4kpjSJKWDl4PdC91v928OyO1ITn75i4Pr5ktMMTvC4cPTWJf.fMUyRAtbyjX7Iu
 Qrgi4q4qpxFhGGoMo5p4cxvGWZYQnoVNDvqm6V4JaAe8IzOa_sAPV8rV6Q8bKg2OiGw7U.mnNByC
 buSuqAqVqmrSE96e3dM8PeiOZDzfxTBwsWE5W4ijFLfFQxkUcsY7RpE_XILieuccngb7PBRFcl9m
 MzCgUHPxS_00GXdwzBvNk8AHeoMBRr__zOR0oDXR7FV_dSdfnqvgaq9qKDfTz3iF9SwMKhPUWZeb
 x4UYwyz8LDcdAWA2WeNvCgrxVIQXUwWhaarBRwKv_F8hN7Kz7bmmb21TfJaKTEphqYrt_EzQrZLS
 8S8KYMffS6wWXRmarkEMkFtIxDJWtBLRc93Y6YEG_4RaBa6Z32Nlfd8YyH98K2wr6JdS1KutAkiF
 F6H2cywHf8RUFxgC3juo57WuFIn8jyIrikcazyti6AuCVTE5r73OoZu82wsj4V9q60kknuBr3J.S
 uu4yyMinPuUnHYT6xqqtoSX6rx_YbqhUx8dTuhrmXR1QbM0SR8dMZKcEO_eatMF9f8udpLiGVBT.
 P45TsafokONAOs0ub1bwyClWO3ndYq6.xe_0CPA6F0_dRdVfrWO8mvMr5a_LHKCaMG3FDo1I.p4E
 qM5LMf.iang.psbs0q6CQHOMhL65DIYJLDlNn0EV.xHlWopsgllQz
Received: from sonic.gate.mail.ne1.yahoo.com by sonic311.consmr.mail.ir2.yahoo.com with HTTP; Sun, 24 Mar 2019 15:30:47 +0000
Received: from pink.alxu.ca (EHLO localhost) ([198.98.62.56])
          by smtp404.mail.ir2.yahoo.com (Oath Hermes SMTP Server) with ESMTPA ID 6538810d4e26107911f82eb677458271;
          Sun, 24 Mar 2019 15:30:45 +0000 (UTC)
Date: Sun, 24 Mar 2019 11:30:41 -0400
From: "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>
Subject: shmem_recalc_inode: unable to handle kernel NULL pointer dereference
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Vineeth Remanan Pillai <vpillai@digitalocean.com>, Kelley Nielsen
	<kelleynnn@gmail.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins
	<hughd@google.com>, Rik van Riel <riel@surriel.com>, Andrew Morton
	<akpm@linux-foundation.org>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1553440122.7s759munpm.astroid@alex-desktop.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I get this BUG in 5.1-rc1 sometimes when powering off the machine. I=20
suspect my setup erroneously executes two swapoff+cryptsetup close=20
operations simultaneously, so a race condition is triggered.

I am using a single swap on a plain dm-crypt device on a MBR partition=20
on a SATA drive.

I think the problem is probably related to=20
b56a2d8af9147a4efe4011b60d93779c0461ca97, so CCing the related people.

Thanks,
Alex.

