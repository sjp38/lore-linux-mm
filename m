Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5AB9C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 19:07:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8151B21905
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 19:07:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nXwzCRB2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8151B21905
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01A858E0002; Tue, 12 Feb 2019 14:07:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0BE98E0001; Tue, 12 Feb 2019 14:07:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E22FF8E0002; Tue, 12 Feb 2019 14:07:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4D328E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 14:07:35 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 143so2764700pgc.3
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:07:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=OpyY+rWGCRjCWIcHJBnUa587hFsQzOCB56va24AW1sA=;
        b=mI+TOQYO/AfkefvoMlEQv48PLpSH4ExrOFlp3jkvdMoU8pi9J6oFz5otvPm8zma9IR
         Jw+FIf5HKxfqrcHcwjno/1WePoiDnZAboparz2XblsaIjFN+js6JcLmFslMf3GGHtuHv
         eNdiF2mfdkGX1QfDbRHXWaBWgk2T3biYtsiLFED0Jv2EPFjGA/w4RBp3OYe/mQO+caOT
         6Et6M3UrCQRVnKoD4Fb5wvPKRhr1bKW56Rg+qlp9CzlsOSH0zmy91jqJQFs5R6hrZRdt
         fTNhIR5mXwwXmuT7bhe0BV7OgAcTtWbKtrlpAB9G/ljM1ICNSrGfbT0Q/hZ6wGEBFldS
         aMcw==
X-Gm-Message-State: AHQUAubIPsmvuOrgUfX+UxmGC4FumGrcM19Q7C0rVi47OvWFDrZECJQc
	iOHD8r4nBC1SxyUdHIMfmkbA0hxymme1oMZb/u305WQz2c/p41e8iX5LMNnGyHJWyP2XEqDJR2D
	NR55xJzDyjFDDSfRpJTC+jD+A2IPopjqAXG6E6fjl3jw+ZuNhwK/fQKW+EPOIzG/Ta0or4Rersp
	QaUvFvVyIRlWdl/UUqrSZ/KV4IVIDYJIUCtiLrX0AcHT7Mnk/6Q6lzaMyzSV3oTHvCqIxzjGJ5J
	ycR9aADiXR/0+oBXlJFD1FBXStZ0e9y398xvMnqNlt/pHNtC8hFDsgvYfpdak3RFaRasvsIvhr6
	dboSpVjsNCgwpPRmmBImLblNEjj3w8XjDgD8kshOtikZkw+frlxsShFCUqtHFxYpP8LTMYhZ4CL
	q
X-Received: by 2002:a65:6645:: with SMTP id z5mr4963117pgv.351.1549998455269;
        Tue, 12 Feb 2019 11:07:35 -0800 (PST)
X-Received: by 2002:a65:6645:: with SMTP id z5mr4963068pgv.351.1549998454532;
        Tue, 12 Feb 2019 11:07:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549998454; cv=none;
        d=google.com; s=arc-20160816;
        b=SpgIvJnEnOvsepebBURxYWkhvGYYivM/E8pE9EwlcaymC9UPfG8j0dpCgp7+IBIcEQ
         HumXLSe1KCUA01RehJiM7o8audKS5OTqEX3/6+CdrmiyqP20tJSq+UZEX1Rm6vO0pNuB
         Bu1bDQQW7xsUA6opGNoLzwHovdRqrDJ7IARKZlxODkep7RF3YOtOArabsaWJPogATy7f
         qa0MoIQYS8L3lTnoUo5U0eiHlGG5Xi/xV3Tj4Hb3G2UPCQ8BBVn0nCkW+GaANrshmeUw
         11o0PIPaeJMgGUfSKRVgResSwzzKV/6Jc4gWpMbK7nbTaZFHIunEsPbUzG0xijavwJH7
         ptSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=OpyY+rWGCRjCWIcHJBnUa587hFsQzOCB56va24AW1sA=;
        b=L7rs2Qo3eBQxhoo3YFLCUb/K4BEiMB992yQqmvV/7jIQQGqyowxmTLLQwq7IgaRA4a
         5cRxTbSSQ2h+9DLDgCyXkFPlQN1WO0BznyHZhOU63q3FSqrYb94KrJMxO1Oh+3Pqo7zR
         BgpzhhNKEb64xPJWENOU4wfT49+C/EV3PLwEJL1cd8/ybL9CpSbggWKhh7CsViURLDz7
         KsBIS25czleXNsYtjc/JdU1gyhxebpusq8dDwH5XqpYzOYeNF7qv3p18oOX6AsM60QYj
         ZesiLFi1jxCmQ7TseN1FsU4Kf74lSHk+ss0L/sJjjNoc9pUVSVavyo6jLI06aQrltEZa
         1qZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nXwzCRB2;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 102sor20469043plb.0.2019.02.12.11.07.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 11:07:34 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nXwzCRB2;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=OpyY+rWGCRjCWIcHJBnUa587hFsQzOCB56va24AW1sA=;
        b=nXwzCRB20IcaOH6u9s6yP3zgt1SGf3oSlamcc6rIBa+zTCjN8F8wxDnSJHxgpoUmBe
         aEBVuobGX9CsTsYo0UpQuNZnjdFlSpVo0gEq/UmDQp7v6q3hXOEI8E7pxzm9ityCAySw
         KfupLnTJm/qL26PkWGs4pVfV34ZfxiEQsTcWm77K6LvtfXgjBK7/6C+dMYyCtGDue3u5
         0wZcSD4zNTtzGDZax2tp1ybb5fZdm7Lkl5D9hJF5rWPdiH8VqrKDJse8GcwRBbvb2RS7
         sYnUqnEwLI8xnOmkQOoFpgkNzkrrpI0vIYNNRCnsWthJNSdogqCbJY79/kPQvzhkbM6k
         WnAA==
X-Google-Smtp-Source: AHgI3IZly9Yr8ptRK7gT1k/BsvVpZtBQyuyHNcQJoC23Cm5pF5l+J4mVKgCH+63VX8FgpINv2H6PeQ==
X-Received: by 2002:a17:902:2966:: with SMTP id g93mr5312125plb.11.1549998453457;
        Tue, 12 Feb 2019 11:07:33 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id e9sm61911867pfh.42.2019.02.12.11.07.32
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Feb 2019 11:07:32 -0800 (PST)
Date: Tue, 12 Feb 2019 11:07:19 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Matej Kupljen <matej.kupljen@gmail.com>
cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
Subject: Re: Fwd: tmpfs inode leakage when opening file with O_TMP_FILE
In-Reply-To: <CAHMF36HKu7S8ezhSbCcNcgwL0cHAVsB_6W1o4PE=rRgVQbMycw@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1902121105440.3765@eggly.anvils>
References: <CAHMF36F4JN44Y-yMnxw36A8cO0yVUQhAkvJDcj_gbWbsuUAA5A@mail.gmail.com> <CAHMF36HKu7S8ezhSbCcNcgwL0cHAVsB_6W1o4PE=rRgVQbMycw@mail.gmail.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019, Matej Kupljen wrote:

> Hi all,
> 
> I sent this mail yesterday to kernel mailing list, but I got no reply.
> So, I checked the MAINTAINERS file and I have found these emails.
> I hope this is the right address for this issue.

Yes, thanks: I'll look into it (not this moment),
and reply to you and both lists when I've got something.

Hugh

> 
> Thanks and BR,
> Matej
> 
> ---------- Forwarded message ---------
> From: Matej Kupljen <matej.kupljen@gmail.com>
> Date: Mon, Feb 11, 2019 at 3:18 PM
> Subject: tmpfs inode leakage when opening file with O_TMP_FILE
> To: <linux-kernel@vger.kernel.org>
> 
> 
> Hi,
> 
> it seems that when opening file on file system that is mounted on
> tmpfs with the O_TMPFILE flag and using linkat call after that, it
> uses 2 inodes instead of 1.
> 
> This is simple test case:
> 
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <string.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <linux/limits.h>
> #include <errno.h>
> 
> #define TEST_STRING     "Testing\n"
> 
> #define TMP_PATH        "/tmp/ping/"
> #define TMP_FILE        "file.txt"
> 
> 
> int main(int argc, char* argv[])
> {
>         char path[PATH_MAX];
>         int fd;
>         int rc;
> 
>         fd = open(TMP_PATH, __O_TMPFILE | O_RDWR,
>                         S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP |
> S_IROTH | S_IWOTH);
> 
>         rc = write(fd, TEST_STRING, strlen(TEST_STRING));
> 
>         snprintf(path, PATH_MAX,  "/proc/self/fd/%d", fd);
>         linkat(AT_FDCWD, path, AT_FDCWD, TMP_PATH TMP_FILE, AT_SYMLINK_FOLLOW);
>         close(fd);
> 
>         return 0;
> }
> 
> I have checked indoes with "df -i" tool. The first inode is used when
> the call to open is executed and the second one when the call to
> linkat is executed.
> It is not decreased when close is executed.
> 
> I have also tested this on an ext4 mounted fs and there only one inode is used.
> 
> I tested this on:
> $ cat /etc/lsb-release
> DISTRIB_ID=Ubuntu
> DISTRIB_RELEASE=18.04
> DISTRIB_CODENAME=bionic
> DISTRIB_DESCRIPTION="Ubuntu 18.04.1 LTS"
> 
> $ uname -a
> Linux Orion 4.15.0-43-generic #46-Ubuntu SMP Thu Dec 6 14:45:28 UTC
> 2018 x86_64 x86_64 x86_64 GNU/Linux
> 
> If you need any more information, please let me know.
> 
> And please CC me when replying, I am not subscribed to the list.
> 
> Thanks and BR,
> Matej
> 

