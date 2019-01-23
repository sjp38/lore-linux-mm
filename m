Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AE0FC282C0
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 23:12:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DB4821855
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 23:12:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DB4821855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7B5D8E005F; Wed, 23 Jan 2019 18:12:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E28D68E0047; Wed, 23 Jan 2019 18:12:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D191E8E005F; Wed, 23 Jan 2019 18:12:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 77FA68E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 18:12:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so1502803edb.22
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:12:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=T0fX1kgDHDO4Xh4qKeBJ34bpp642Veh5A09kgU+526k=;
        b=faahf/ZEKgle1W5oNjT60zxzqKuhPqX1NNNvPmSysBg/qYIj3blcooczxdO0/iaKEs
         /dr5EQzFokubd0/PxXxnvrPGdXj1Ff0GE0+a35wH2ya6afYfcmCqT+NlH90IHG3rylFp
         YKxqaJ5UqynYLrEmoafa+/jgdeqfhQ4sC19+55F3SjVS/mAPWTB7vH8SJXDQya4PtoqF
         6t6Yfeyhvc2lPpxMJOv4BuNMnfk805LT2wl5Qd0ON/hnOUpOBdieOmUsmh5/JIKLI4uk
         9XImFdfzXhtLTf/0LuH/ODzo7Y6Fcmu9xXjMY6+tOC2dVllqnEGjHVnC4nSKxLDcDfhD
         Ue6A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdx1f+wocTNR7UFtABdHL2ZZ8MQBmJisYZEjXYwKikxtoFTS3YB
	qdG0FrnnexJO39qSordLSnO24XsCs1OiWiiJ7m3k6JAAmT/k7hwcVbQRr+GJtYTsy6g2x6WYORN
	MzTUx0kh2t5GLRHxiDCU2EqyO6enVZwLDGmWlGV9Xsm4SUpqtxoNpajt24MDLJOE=
X-Received: by 2002:a50:8163:: with SMTP id 90mr4425539edc.174.1548285171043;
        Wed, 23 Jan 2019 15:12:51 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6el7X3xHwACzpwqEQonTbt76jmSnFYl26xfOcAanX7kbOJNDgh3BWOTlOBQRKN0wFCkTxu
X-Received: by 2002:a50:8163:: with SMTP id 90mr4425501edc.174.1548285170165;
        Wed, 23 Jan 2019 15:12:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548285170; cv=none;
        d=google.com; s=arc-20160816;
        b=yFCo78ayeNGj0SwVTKQIhMM3/WXNQfCcxzjbd/WRHOaoEKsYDBDEDns2C7qCxJcEY0
         MzqX626cX9fEK2WgfMEylyGeoB+sKp7a0L0/iZkz1Y+GQGRUwRv3ZylEraKWqltMjUco
         sSZMIDdQgEZsjqs3+kmo1LijBkCZqCk4nbFb+/ssWBn2XRAKQi4leo/pK40i6+7zU6R2
         t5yGx1mawFsWJ5V6U5g30V2BMWWU70kJ/uxxc7yOEmqG0EKfUqyT8DlSna3br6maY64I
         HysvHuMsmJp4LKiHMEfd5HphtLvZvkez2t6sOzwHTubXYsRkDxW9nCBqDEronSKC647s
         C28Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=T0fX1kgDHDO4Xh4qKeBJ34bpp642Veh5A09kgU+526k=;
        b=QVXhAi72rHAja7xEmDEqyn9d8o2IGnDl4ROOg79EwszK8za0Z7JNOkerlUeDqWazIp
         owVjc7DrDu4oKiZIIyivahQCMH0pzzeeFAXeS6q1ikzYhjTeIQ1idD4UyYJIgaGuVRjq
         Bg4uFE4P7Hgsh1i1vA3pvlIfBT/uRsFJNadMefl8KH9dzZZ9m9Dd6hU0d4gHRXzvMCMF
         87KosOFJRt9nfRZXu1QUxbn3FeFXqx5w+t1kBqFhORVORDDIlAIRQTjOB9iSdesZS04K
         dQo3/8Tv1j+NbduI4+lnTRdULxk4uD31Jmgf4NHAiWfKpbbxfUfL2IDxpdSUBpbFBbAx
         r2kA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si722550edh.283.2019.01.23.15.12.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 15:12:50 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1E373AF26;
	Wed, 23 Jan 2019 23:12:49 +0000 (UTC)
Date: Thu, 24 Jan 2019 00:12:47 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, 
    Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, 
    Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <CAHk-=wgy+1YT-Rhj5qWb_aCuBADhcq42GDKHB74sqrnOVPKzPg@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm>
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com> <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com> <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com> <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com> <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
 <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com> <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com> <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm>
 <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com> <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
 <CAHk-=wgy+1YT-Rhj5qWb_aCuBADhcq42GDKHB74sqrnOVPKzPg@mail.gmail.com>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123231247.9g8CcrS0b1Q6vEQtU-rR1AzM_5zVN5_Xguq4LyoLU6U@z>

On Thu, 24 Jan 2019, Linus Torvalds wrote:

> Side note: the inode_permission() addition to can_do_mincore() in that
> patch 0002, seems to be questionable. We do
> 
> +static inline bool can_do_mincore(struct vm_area_struct *vma)
> +{
> +       return vma_is_anonymous(vma)
> +               || (vma->vm_file && (vma->vm_file->f_mode & FMODE_WRITE))
> +               || inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
> +}
> 
> note how it tests whether vma->vm_file is NULL for the FMODE_WRITE
> test, but not for the inode_permission() test.
> 
> So either we test unnecessarily in the second line, or we don't
> properly test it in the third one.
> 
> I think the "test vm_file" thing may be unnecessary, because a
> non-anonymous mapping should always have a file pointer and an inode.
> But I could  imagine some odd case (vdso mapping, anyone?) that
> doesn't have a vm_file, but also isn't anonymous.

Hmm, good point.

So dropping the 'vma->vm_file' test and checking whether given vma is 
special mapping should hopefully provide the desired semantics, shouldn't 
it?

-- 
Jiri Kosina
SUSE Labs

