Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8B46C282C3
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 14:46:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F34121019
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 14:46:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F34121019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D023D8E0003; Tue, 22 Jan 2019 09:46:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB0DB8E0001; Tue, 22 Jan 2019 09:46:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC7CE8E0003; Tue, 22 Jan 2019 09:46:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93B0B8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 09:46:04 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id p124so3345372itd.8
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 06:46:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=tZ75i4rbvSM77zRbeSNhYTFR1GllBSkW3HGwpNt3Sd8=;
        b=gRGnh4BTAeRQCfrSeBT3Uwddg84YWhuuSK2ecP3ntcG8e/HsphHFkLn6h9lb3iR3y7
         1tzlRe+WYDOXV7x3WCqSKnpSxMEvvedJL6WLv+gqJtgDYdA9hWzj+S7uPd/KHu+3VKVZ
         FszXC2UiI83VX0DvpLIL22A4M4451u/s++MfX2oq9mvq/lRXwSjlZWfU2AbhVDhyEX4U
         7doe4w3EuEOiO1KRrPPh+eNziwTZlPbxiZYOirMcejXLDZbgbQeZHV+QazMXz9vxNdQC
         x2cZXnZWvblJtU6Z29WBC4Lfqs0ARoGZ0+mqAlc2/bSuaxtzygYGCLNAxqG4ssE7q+2W
         j6mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3qyxhxakbaao289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3qyxHXAkbAAo289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukeNsVRKO7m+fGWytfUEEY5KIuaDN3YKpzoqnbP10SUSXh9ptlpG
	yQeEpQO7flB8jSucVRI+cJiHnxgvcVaQqmsDgUL69QOBt3+hmxLYJnEEioBpGCkDpsf6nFEhzml
	EWhtbeqoxlzPNX6i1dstsN5iakNJeMSciU4hepJw9vslEQHY5bqRwhh1QZTUeCNHEVlkIhP7Yaa
	hgUBouMq/Yc27JwcBL/yOUdjX6E4yZR+0PPM+3s1+EOWCbkpuCe/1TGvKp2uTVJOsg5w9Lux3jZ
	023PS6SE60ItG0GcEIB7BPjzsUkHowj8GyUGSZ76lKHdSUzantaKOnzcebfpW7hGeeQRcFFo02l
	OjZkrKA0llK/YJvHJErXHBqwT8e4L/fR7Dj73HERziEkdYK+DCjv4KrEY+U3C9Fil83Kvnr7Ow=
	=
X-Received: by 2002:a24:fc86:: with SMTP id b128mr2329276ith.93.1548168364315;
        Tue, 22 Jan 2019 06:46:04 -0800 (PST)
X-Received: by 2002:a24:fc86:: with SMTP id b128mr2329230ith.93.1548168363364;
        Tue, 22 Jan 2019 06:46:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548168363; cv=none;
        d=google.com; s=arc-20160816;
        b=OQk/+ssNCHTflm2jz28qBUtkOLdlCfK9w+9Q9QHrtzTF7L1qjPVpxYHwWZZudtl3iy
         wHrXXFt14kgbK+qyZfu/Ex71F9GydFZED/v9vqwT5a+SFAoMcVitGZR1rMMM6h6b5UBR
         ahckZt9vt51OYLNhvFvfsOi/guKbPTLd503dc0qKGifUs5AEC9ttNlTuFB75H6FduBlH
         CM5n1XKrWGb+Or3Ht0HIHhKmJto0utiWeA3T4t0E/ArNC1mRTtGKRJg0+giuNSDBvkfb
         6d2/L/uixo+Oueb/h7tmx4vmF+mPqPWN0cnp36L1EzcDsIGee/SdDvNS3yGLcpNHQDEC
         7ElQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=tZ75i4rbvSM77zRbeSNhYTFR1GllBSkW3HGwpNt3Sd8=;
        b=jCXgJKsc0Ns4TljXWq3TVf1mxNmA5zhCW9VRMrrnRDrMDP4q2xKz25pY38NnYAeKTh
         8IUlr+8wCiFWnz0d3W6hJE/EIGKvN4dpNcejJjc7xiheTE1UVOqcx9cegQZuTUBTQ023
         wfJYGWg3oMkkmpEKNfPukXamta/etvrZvp8CFyChrvQ0k7Ls4JyL1N/7XmPiYyTYdEqE
         MhbCANJrQwoJNh/gzFju6L3TVkqyXJfN/rohSDySrBRhIFLy0SBgLFdynG36mfmDoOSh
         NbpSZ5+fqzFoTyDLAhWhAh714n2kLYgFxYaL0Zkr3AXNquTysmiE0Kool+wrG5z6UEwa
         Op0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3qyxhxakbaao289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3qyxHXAkbAAo289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id d194sor8302622iof.116.2019.01.22.06.46.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 06:46:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 3qyxhxakbaao289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3qyxhxakbaao289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3qyxHXAkbAAo289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN6p8giWAHu3JMN3RnBjUiUatuUrVBTpnvYgJFWxz/LCZYQAwSYrekaoWTh6GWbMEDf1jW/MHGAAv/4QDE9z7F0IXyY/XD6L
MIME-Version: 1.0
X-Received: by 2002:a5d:9ad7:: with SMTP id x23mr917387ion.21.1548168363115;
 Tue, 22 Jan 2019 06:46:03 -0800 (PST)
Date: Tue, 22 Jan 2019 06:46:03 -0800
In-Reply-To: <CACT4Y+bEsav4r82z5rE1b0rH==VpU7FEK7DzuqTu3AV+w0Ve9g@mail.gmail.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000005609bd05800d09e9@google.com>
Subject: Re: possible deadlock in shmem_fallocate (2)
From: syzbot <syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com>
To: arve@android.com, dvyukov@google.com, hughd@google.com, joelaf@google.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	penguin-kernel@i-love.sakura.ne.jp, syzkaller-bugs@googlegroups.com, 
	tkjos@google.com, willy@infradead.org, xieyisheng1@huawei.com
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190122144603.W0626Hq-QR-e67g9c0wws8_onHP3nD-z1N1qnSU7wVI@z>

Hello,

syzbot has tested the proposed patch and the reproducer did not trigger  
crash:

Reported-and-tested-by:  
syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com

Tested on:

commit:         48b161983ae5 Merge tag 'xarray-5.0-rc3' of git://git.infra..
git tree:       upstream
kernel config:  https://syzkaller.appspot.com/x/.config?x=864ab9949c515a07
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
patch:          https://syzkaller.appspot.com/x/patch.diff?x=1064a9a0c00000

Note: testing is done by a robot and is best-effort only.

