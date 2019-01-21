Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC505C3712F
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 21:48:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CA5720879
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 21:48:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ieSP1I9H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CA5720879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28F7A8E0003; Mon, 21 Jan 2019 16:48:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23EBB8E0001; Mon, 21 Jan 2019 16:48:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 155BE8E0003; Mon, 21 Jan 2019 16:48:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id E19B38E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 16:48:53 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id s5so17596320iom.22
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:48:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=x7UAzhxhYqF5MWQe8FEEyUUkSs2EO4xS/Q0CLMrkaXk=;
        b=lOzaly2r2GSrHlicky50BxwkHET5SkTEI4i2hm8NtGosQhSpESE9kA4D3taqhVB+Bz
         H+Vn8DoXZbrJWYbO/ZdUBE8LBJMxe8puOHpdweg46xFCEoJ7d4Ze1dirVFo4MYXCYu4/
         UkxrTuU/031nUAHb2bqw7Lp3KoTz996giAegyNP/HfPbxDktxbtNMGPDcFtCm4frjIhm
         Qc1ygfLcJUrecZRcoiICLkHiMDK96f/QwGe1U7GTiu8iqftp5FLJD51IPsNAh+YYQeZA
         SAPGOifkRLm+qeg8bdoP//Alory+lobD+Zk/+2X0ZK92kg+VPP3KodR0baKoZ/2Q9d/z
         u66A==
X-Gm-Message-State: AJcUukcmP7tmjFGH+a88bH2EwvQXLmWpbNQXeX35lUcx9SbGt7liA3cZ
	0o1LVJ+oIZrE0r3zjFU6pSnqBYNg4xdRzIMDjIGd0/G+jvNl9O23c9pXAeGamLJskiFkkzz1SGc
	A1Hj4lZKOednCDZzWYOaZJI9MoFxL2Wq36fpfm2GCE4CAAOVbS47/fADXbyUs99cEKuU1svsFVi
	Fvq7Hga2/Qa6hWmYOVCBLLPfjHIBiD4orP72fiPIq1BAyt9hXYBcC9uyvy+gQg+HRdZWft+cd7l
	mbUrednHxCI4SzeQKEkwL/Uk61kZg38b0uKiah6b0wBLufCnPXUAgMR7h9V6HxsaYTo52GiUYZ7
	kf5es2FUKwOhaUF3COMcUvcM4VUOGz1yi+WFz9UikqebA/9VIALhH5/unKNKwOsnKK3MLnHwYBg
	3
X-Received: by 2002:a05:660c:6cc:: with SMTP id z12mr263737itk.65.1548107333694;
        Mon, 21 Jan 2019 13:48:53 -0800 (PST)
X-Received: by 2002:a05:660c:6cc:: with SMTP id z12mr263715itk.65.1548107333066;
        Mon, 21 Jan 2019 13:48:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548107333; cv=none;
        d=google.com; s=arc-20160816;
        b=ysfOLJeO4slN/c5NPJpfvx0ahdL/FDZkYnGMG3BxteemJjzb/jDlBwV181T15bDYCs
         lp+LkhUHInA4ag6slAUcTFLRzM2w9S4lmyuF82l60W7ZqrIwm6gVVYrZWIXQ7N5loufL
         4y9MSMVmLNOf7MPKd9o8uf5l1XTMDREHZH1LNoPQV7j9pDuVZEK469YKSwxyEZlPIjXE
         I/PMeMhSuFc0xO3TKaD2JCc7Dscq5daGlPRcVu0WUKO+u8/ubm3CdSvqk8CHt3ASnbSa
         8f/vgqtu6Tzdmx+F7dSYQs1XnQ0sa6Hw1WC2ytqQemYHq0XxchTYLwN4IdvNrPN7KrFY
         zZtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=x7UAzhxhYqF5MWQe8FEEyUUkSs2EO4xS/Q0CLMrkaXk=;
        b=p6QuhOrsGT3SgQaqwDLQgrAs1tG3Gu4Pi28m7XT7xbhrOEAncNXOA8eSqm4PlN/qpt
         cc+ALhr+m6pMNmhOnXs8KSkYCvqnzXTzNkJGxUdlylNR1sL4/aWMjvfLBCtApZDe6lom
         AwQOUykaCktaam3PVjx9Xvli3KGoag5TfOTtO/+mEZDYE9uO6lp/qhPpq0kNL/IBb2P6
         OEZRVij3fa2MrhDxevzRqGZJ/myoT7wV28nKrTJUCeh7dtpy7VWq+TEps6g/sfb7Wz+/
         Wlv8NKS9J9jyspZq0PgNyimfOehzjPDDUM/fv6Z3aEedk097y4sn5LtKCX3eXf+Ze9Zq
         KiWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ieSP1I9H;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p11sor21790833itb.1.2019.01.21.13.48.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 13:48:53 -0800 (PST)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ieSP1I9H;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=x7UAzhxhYqF5MWQe8FEEyUUkSs2EO4xS/Q0CLMrkaXk=;
        b=ieSP1I9HrJ9ZWab0gbTr8LYXjgHi79AC4/3BhSXI77hHT91FA/ZukJOeHjIV8Ox+Hm
         oOALLkHkEFkSbcSMASrXa1DD2tamhW4Nrz7bH+6/MIPXCPZKOlqaQcMVXbh45mylbpmh
         qa6E2U+Or67R0TAYc4h4Yi99xrcVmwrnSWYuH5VJKxUebXSY+5D6Or/lZBK+aPb3w7nA
         T5fyik3e0PE9Oi6kALLEhBhL6gfzlkFneAFuSM6N9XMPaiIuNKa3nd1ivb4U0nI9Ediz
         YOH/3nF60jJ07SuKdnlARvZm1DBVxRT6JosfWQWb/zFoYQon9gJjbubGpk7gN3z8Q8uV
         MsDg==
X-Google-Smtp-Source: AHgI3IZNnAiS0Sm8G2yKZEX1KaVGmEJ0ujjvsJwi8+bEIGjvy+8VpWO7BS2GAyvkwNsFlGde8L0i3M6icbd0LyeLC6I=
X-Received: by 2002:a24:2e94:: with SMTP id i142mr814111ita.157.1548107332434;
 Mon, 21 Jan 2019 13:48:52 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsMfWW_jA4vVfzr8MOLfqj2kz_AYyn5Ve48dxe1DtAbWXw@mail.gmail.com>
 <f3647d02-083c-d3f8-597f-9a98095d20f1@amd.com>
In-Reply-To: <f3647d02-083c-d3f8-597f-9a98095d20f1@amd.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Tue, 22 Jan 2019 02:48:41 +0500
Message-ID:
 <CABXGCsNbjYvoc=QtX0fbW0V6T8dYzxn29yUGDD0CieL5s9GCtw@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
To: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, amd-gfx list <amd-gfx@lists.freedesktop.org>, 
	"Wentland, Harry" <Harry.Wentland@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121214841.a-2t2vPQjPxZkcHNCXuqHBJeP6__9FNmUqCMcvtW1v0@z>

On Mon, 21 Jan 2019 at 22:00, Grodzovsky, Andrey
<Andrey.Grodzovsky@amd.com> wrote:
>
> + Harry
>
> Looks like this is happening during GPU reset due to job time out. I would first try to reproduce this just with a plain reset from sysfs.
> Mikhail, also please provide add2line for dce110_setup_audio_dto.isra.8+0x171

$ eu-addr2line -e
/lib/debug/lib/modules/5.0.0-0.rc2.git4.3.fc30.x86_64/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko.debug
dce110_setup_audio_dto.isra.8+0x171
drivers/gpu/drm/amd/amdgpu/../display/dc/dce110/dce110_hw_sequencer.c:1996:25

Thanks, I hope this helps.

--
Best Regards,
Mike Gavrilov.

