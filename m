Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5D1CC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 07:45:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4490D2083B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 07:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uFQRCKd5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4490D2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA67F8E0013; Tue, 12 Feb 2019 02:45:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A55988E0012; Tue, 12 Feb 2019 02:45:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 945D48E0013; Tue, 12 Feb 2019 02:45:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53FF58E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 02:45:10 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a2so1463853pgt.11
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 23:45:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rQSmjdcB+ssMiEN1R8if29u9yg61brahFdCafNDHO+M=;
        b=tYtqvc0bbsOXeTsTOxEoiRBPl7IQ82OIlhA8v9Ma/6SOLnNAnakiuq8uJfijwUoxse
         YbF67LJ0wwReONkAqrOTpPLZr3KSJulknYugTvbI1EroyYqTaIk0/QVJrpsm1gQ8RmfO
         y0g5T8LgZdbEB88bw4wPhfy2i0k+cj0GVe3Y3+pgSF6R+lhYfhwInZF59e6E8/n8yLEQ
         zCMaY3wZuQX2pJZj/WdHa+u75XCAyclU7g9snwYeDZ9DKh247RUXCB3tc8JhkMfiJib7
         iWLCiWBKhmj8HmFvTVx4r5abshkeohKoeg2J5mN5x8SHQAGUk1DB98xQxsepr6U+8JJH
         BG/Q==
X-Gm-Message-State: AHQUAubQRrtt6C8IRkwWChg9zrcmvPmZwD8ZpCSZobi7Eis76Uj+z2z4
	VVUtLGMsJ/wqCCkDKvFJ47CRHc69OsTMpRebg++I1TDKinLXJjT+oMhMDF6nrMY9ovpjw48BOs1
	odaBjBLx/SgwEDtBfMxkhm3MjbgZrOieFHzAAR3LcBDRWqwl4KzN0UJONolaBj8MClj7/DZSLLt
	WzkKNdzjKIBqOfKWwjlvWSZTiUwFNW+ueq6qa3yrNZJdQeOM9c5JYFe++VtMgv8oG4B8myXPSJn
	Xd4NnHa2fG1SAzEYeSUdyLSSLr98Q3Kpc+7oZgzsqHxNXfMUwytOo+XxJ5okjI6vbEOcevBca11
	8s8SzuZ1VN/8A9NQf36N+BKdDfSE4GxBV/4FM3NXPNtuQG7JywNUyReOQx110Y50FGXw/f4X9V2
	I
X-Received: by 2002:a63:fd0a:: with SMTP id d10mr2473512pgh.164.1549957509918;
        Mon, 11 Feb 2019 23:45:09 -0800 (PST)
X-Received: by 2002:a63:fd0a:: with SMTP id d10mr2473464pgh.164.1549957509129;
        Mon, 11 Feb 2019 23:45:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549957509; cv=none;
        d=google.com; s=arc-20160816;
        b=Zr7Yoac+Xm05qj5KrKmoyO37m8jWg5B1bdfh/ltNZ5kkOagqp9em0zsYWh86pt+9BB
         caDsZvzcILrL6Wk0SXB5ftqAYsZNiPIHpfbEdnnHaOIeez13m54P8QHHm/6339YKNrln
         BGhMGuciL96ShqsdRwrQ6soryDCsWx19AAgIydDuYqavyvinu6rupPvhX9MMiFjy3BAJ
         hxFOFBIisw654j3b3x7ZGRUaxYCI+Q+Hm9o5zDOgsk5mNbne7NWW/CJgQzTznMBSd/fb
         sN8dAdWzxvurnGFq8v2r8KJ29UmZziDSTz/Gb8jfLG4wO6LyJgEdWooe6uNZsaU33Do+
         MddA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rQSmjdcB+ssMiEN1R8if29u9yg61brahFdCafNDHO+M=;
        b=a9/vzi1ZdzI2N5bagnfQy70REX3U9T/ti9ix5/x/AWcVBD4TpBxcXWAKnj1ZD6RN36
         xrS0035MGiMQ4RLFGYgLoG4HcIL8/RzqJKurkWaAkaoRxt/pS/H2Q4wrQM2uYUVd1m0d
         qcVXlYJFfx5mip86jEWw/cneqvrhqJxNoyA51aOVTwFizPqD9gLgv0IXLhnIk5DlzidS
         IvkWAjXpVX6OpN88jvn4E3wLYbHQ3k9oP+9MckksjRSIRSWA+XC2TFy6hJbiReGrnnk3
         D1Cvtm5Ib7JPWmESekKxB1qqO2LPs1mUvvwp7Nzxgo2jopGOgZEiYpOm1AjafCinMgUM
         M/8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uFQRCKd5;
       spf=pass (google.com: domain of matej.kupljen@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=matej.kupljen@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x19sor1187033pfe.73.2019.02.11.23.45.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 23:45:09 -0800 (PST)
Received-SPF: pass (google.com: domain of matej.kupljen@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uFQRCKd5;
       spf=pass (google.com: domain of matej.kupljen@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=matej.kupljen@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rQSmjdcB+ssMiEN1R8if29u9yg61brahFdCafNDHO+M=;
        b=uFQRCKd5uriQtFgQXVzXmt9iYAIXLkWqNExoFBN77E2Bc7mYGfZT3Kz75JJqi9VdkY
         D+hwiIdMUdLF4FeNr7wjEUVXBRWcpXuCOxTzmWRQaQWCWopCYfYeSpXrOQG6HUFVTMc6
         rkTiWhP7viGZ4667N8J1mZLKDlufl4/aqrlTksiGbHDrl9F7wPg0avhB0URLOzih8yqp
         UGc+Gm6uhOtLJDYfb4coy43fIlXa13Z55ZENSHmwwO4DMV3zZDRfgsEh5PHvj5O+0Os1
         8Yi5t7qKReR5uyxWQDDCAh9Bs2Qve9qK1Pvv/ZSYOQlQfrf3KRE6LhWKhEu/FkJ1YDB6
         3IlQ==
X-Google-Smtp-Source: AHgI3IZ/RTihHZ5997O0pQvxZSEWfmWrlSHyTNLSmmKPaqTbBs2pBCcaORMkssa6mLBlQegMhO6TPDGwRvL65kIZ5Fw=
X-Received: by 2002:aa7:808f:: with SMTP id v15mr2729177pff.30.1549957508630;
 Mon, 11 Feb 2019 23:45:08 -0800 (PST)
MIME-Version: 1.0
References: <CAHMF36F4JN44Y-yMnxw36A8cO0yVUQhAkvJDcj_gbWbsuUAA5A@mail.gmail.com>
In-Reply-To: <CAHMF36F4JN44Y-yMnxw36A8cO0yVUQhAkvJDcj_gbWbsuUAA5A@mail.gmail.com>
From: Matej Kupljen <matej.kupljen@gmail.com>
Date: Tue, 12 Feb 2019 08:44:57 +0100
Message-ID: <CAHMF36HKu7S8ezhSbCcNcgwL0cHAVsB_6W1o4PE=rRgVQbMycw@mail.gmail.com>
Subject: Fwd: tmpfs inode leakage when opening file with O_TMP_FILE
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I sent this mail yesterday to kernel mailing list, but I got no reply.
So, I checked the MAINTAINERS file and I have found these emails.
I hope this is the right address for this issue.

Thanks and BR,
Matej

---------- Forwarded message ---------
From: Matej Kupljen <matej.kupljen@gmail.com>
Date: Mon, Feb 11, 2019 at 3:18 PM
Subject: tmpfs inode leakage when opening file with O_TMP_FILE
To: <linux-kernel@vger.kernel.org>


Hi,

it seems that when opening file on file system that is mounted on
tmpfs with the O_TMPFILE flag and using linkat call after that, it
uses 2 inodes instead of 1.

This is simple test case:

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <linux/limits.h>
#include <errno.h>

#define TEST_STRING     "Testing\n"

#define TMP_PATH        "/tmp/ping/"
#define TMP_FILE        "file.txt"


int main(int argc, char* argv[])
{
        char path[PATH_MAX];
        int fd;
        int rc;

        fd = open(TMP_PATH, __O_TMPFILE | O_RDWR,
                        S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP |
S_IROTH | S_IWOTH);

        rc = write(fd, TEST_STRING, strlen(TEST_STRING));

        snprintf(path, PATH_MAX,  "/proc/self/fd/%d", fd);
        linkat(AT_FDCWD, path, AT_FDCWD, TMP_PATH TMP_FILE, AT_SYMLINK_FOLLOW);
        close(fd);

        return 0;
}

I have checked indoes with "df -i" tool. The first inode is used when
the call to open is executed and the second one when the call to
linkat is executed.
It is not decreased when close is executed.

I have also tested this on an ext4 mounted fs and there only one inode is used.

I tested this on:
$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=18.04
DISTRIB_CODENAME=bionic
DISTRIB_DESCRIPTION="Ubuntu 18.04.1 LTS"

$ uname -a
Linux Orion 4.15.0-43-generic #46-Ubuntu SMP Thu Dec 6 14:45:28 UTC
2018 x86_64 x86_64 x86_64 GNU/Linux

If you need any more information, please let me know.

And please CC me when replying, I am not subscribed to the list.

Thanks and BR,
Matej

