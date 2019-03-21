Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B4EDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 15:08:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AA3A218D4
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 15:08:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZL/Jn5FC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AA3A218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB2496B026A; Thu, 21 Mar 2019 11:08:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E61FB6B026B; Thu, 21 Mar 2019 11:08:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D520E6B026D; Thu, 21 Mar 2019 11:08:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85F136B026A
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 11:08:31 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id i184so1423754wmi.9
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 08:08:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KWQHZNFAS4oVh7zkO+Q0eMShMF/EDig7QPA8voBrsjU=;
        b=gPuXAT2Oq4bq3edwta/6IiWPVcosMgjKUde/mtxFTV25WYSue6J0rIBbmh/rFAX+N5
         U0eG/Iaigx05osbr1jW58Gwc0Y8rz3ijw6baKfKgcQ5JxAhM5ow9kYMk8gXubW2U2bgg
         GkB5/ySMCGbTdCwMZwNECXkH05r7EAcZJt0ixl5ZjVVJPiMZSsvlJW4Htu4sp7xbKN+2
         7A+3ssiaySAHuiydntNoiKUtzkTh2cYood57saFgywhLZkVUGcOyuH+nxvRFbc9sM3Gl
         hB4AxsgzhWVt/8wlaJ5VmHarfoBCvHlXSmMMGITFdQ0sRhWu773lc1M5lGpl4kscR4CA
         6C3A==
X-Gm-Message-State: APjAAAUqzTuHDhj1NSmKVLMR0kzK/uNAfpgQj9k/aWbC46DjK9Clvec4
	4Gf/wVPbhRqFnso5P11S8ReS0sfJl1YhQ+u0W1OaCUtAkeayhAjKYiaC9y5/Kg+Fe6l6pZDM6Dl
	H4iMEa/d9wsJyAphGW+GyhZFy+R/mc4yPuca5vMuVdJ1TPQRlmdMlMKArP7VPkXle1A==
X-Received: by 2002:a5d:638d:: with SMTP id p13mr2884847wru.202.1553180911139;
        Thu, 21 Mar 2019 08:08:31 -0700 (PDT)
X-Received: by 2002:a5d:638d:: with SMTP id p13mr2884790wru.202.1553180910109;
        Thu, 21 Mar 2019 08:08:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553180910; cv=none;
        d=google.com; s=arc-20160816;
        b=N9X6vNGsGTcSZPlXeTteYb6W8W9adKMyzrnY70XzrUEEi3HRF0ESaGBbANPFv5TQZ+
         A08aWj65GEUJFFLXAYVqw+G35D2YCMVfh70kDTHlsKcIAUM63zuiWKnykxqNRCJzprEe
         YAtjMPgNVL/UOeG/F7r4FL9A6qMYNNM7s9v6KJ/+K6hGdbDG2twXSCRf83AJypfwouCj
         GOPE8qTrW2BCpIer+kXeWLEnvy2pVSp3OW++YiNnt/O9SC+9mmsuyAPJbAmUvRyfy5XP
         qydsVsEbT/qJQRwGD+1AVsSyb8cmWmw8t7sRTmwwAP4nOwbtEP671eQjn3t362tdWWR9
         nz+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KWQHZNFAS4oVh7zkO+Q0eMShMF/EDig7QPA8voBrsjU=;
        b=oI2/SHempaqqQHUULkMnLnLEIrUTUn2FTcO6hf9QNSH80G3cMu6Nq7+8kgd6MlCWNg
         r5Int2U2bkW1KPEocL29V+ls5Es5GQNwErFubQL9DLJHDlLOLXvgvdCPFzZBEOpAdPKL
         9Q9nLpr8QR+fRDRKUPwsGh62eDDbED5Z3eUFSee2s0jccvZYWUy/NPCAcqnQeQ4Gy+SL
         s8uGiihwDKyc7P/Tp9YsaQbJuERmE9c7GhQpXVb6KcjYtx5RDEiWVEVszZ/+oi+2bMVB
         09pkLEI6JX8jDUkL+3eEq6eJslA0Xd8x2z+dfwHfLCumwRJNU56Xg7gnZYwWBdOKUh2Q
         Nn+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ZL/Jn5FC";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z131sor3812782wmc.12.2019.03.21.08.08.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 08:08:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ZL/Jn5FC";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KWQHZNFAS4oVh7zkO+Q0eMShMF/EDig7QPA8voBrsjU=;
        b=ZL/Jn5FCHb4RKYX/f6PAJxDfwS/tXCiVxEGm4bE97vPoaZ66lr9x2C67E+BID0f8e/
         Iq77g2K4qiXZ3WCz3ebv0diLY2ZpXDYmErpdB0RK5OEWp2cQopwmBIMKfopojhg6y+Yh
         V4NBlwOKhlI9c7y9xCC8N7pSoV9tBKqaKyQntoiPtr0x3DVt332CXsXrxHVckOZ2Lp8n
         3WFeE1ldlfi1CQ4q34j8hw1UD7W/7Wu5hxqtjlTkYqYUYTEZbcgyf3Mih9ZnTGVLbNIA
         l8iFrd2zATTeZX+jfI1QABv1PGCpnpFpqAYBsbLSuE3SQSylEuWBguGDveBLfvGKyMUd
         KPDw==
X-Google-Smtp-Source: APXvYqwrHtS3i74Pv80Ry9pMxvsUFJwu7IXZc7S2CATs3PtmgoUPV/5FkavUcfilFXOY69dh9j8PFgLhyw9qRoQ/e+o=
X-Received: by 2002:a1c:e143:: with SMTP id y64mr2745363wmg.141.1553180909460;
 Thu, 21 Mar 2019 08:08:29 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com> <1553174486.26196.11.camel@lca.pw>
In-Reply-To: <1553174486.26196.11.camel@lca.pw>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 21 Mar 2019 20:08:18 +0500
Message-ID: <CABXGCsM9ouWB0hELst8Kb9dt2u6HKY-XR=H8=u-1BKugBop0Pg@mail.gmail.com>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Qian Cai <cai@lca.pw>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, 
	mgorman@techsingularity.net, vbabka@suse.cz
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Mar 2019 at 18:21, Qian Cai <cai@lca.pw> wrote:
>
> Does it come up with this page address every time?
>
> page:ffffcf49607ce000

No it doesn't.

$ journalctl | grep "page:"
Mar 18 05:27:58 localhost.localdomain kernel: page:ffffdcd2607ce000 is
uninitialized and poisoned
Mar 20 22:29:19 localhost.localdomain kernel: page:ffffe4b7607ce000 is
uninitialized and poisoned
Mar 20 23:03:52 localhost.localdomain kernel: page:ffffd27aa07ce000 is
uninitialized and poisoned
Mar 21 09:29:29 localhost.localdomain kernel: page:ffffcf49607ce000 is
uninitialized and poisoned


--
Best Regards,
Mike Gavrilov.

