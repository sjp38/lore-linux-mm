Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C183EC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:59:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8867B214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8867B214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F74C8E0003; Mon, 11 Mar 2019 23:59:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A6988E0002; Mon, 11 Mar 2019 23:59:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 096208E0003; Mon, 11 Mar 2019 23:59:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5D928E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:59:01 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id f10so875219ioj.9
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:59:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=Rg1C2aX0HyUdcFpVwU4EWVeEJy42p9kXBaO9Wh8/VOs=;
        b=jUoGoDBHAy4jf4UAPpe6oESI1+ogx621knr9t7wGFSQ30cy83L57Y+X2i24GWeKiEz
         yCNillEKOKUT2AXCx+kq2Qr50oPZAJTtvDTntQlAQBCtTdaWEzIDviGrcZX6DwZndDgT
         zf46GGMYpwe1ouH1oUhzEcatkojBdOOX/hBy8+TcUV/XvQbBQcdFGujS+XbAlb2gV2U2
         VNX+enoEthU3hdlh4/llceEPzBCCdFUBBsaP1RxElnAq0ZkkLSwmfTxuQlZckVbGEUzs
         22WGv+bsHefM5kgKrSYJi09Pz/UQ6BcYsyzaEZ5WRF5cHLNCVRb4N6+9FkKG14EeFzah
         aWkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3hc6hxakbaocbhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3hC6HXAkbAOcbhiTJUUNaJYYRM.PXXPUNdbNaLXWcNWc.LXV@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAVgP5vFQ+dU4kpaHhcmfGutO9wmhgzXwVKj9HWBssdMmYf+1b+f
	KUSUuo+yU3DXQ2OUjBlZBx/dUMPjAk/tJW6JtIyVjlICBzS6cV6ZBuB5WZ/o2h4lVCqMwNdUAUJ
	IuMX/zSyayxAdWtOotMs2ndXbjcLzJUwLGgSIotd6MUIG5paUushwgppjH+t2b9Tv8jf8tSa3gh
	t5PNW9jHe9WJ830iYBE93+T+hKBxv7fcGoj5G48Bo6mvRFxizntFkJ41/XpBXFH1VCn+w0ywAVy
	HGN6JtZew8HrDtyVoXq1C5bfYmDtwSS0YEYliX2XEds412oxJkf02nZvnnaBbyeJjyhMi08aI5r
	WoN1gulElnZuZDdiK3wDhenW1GvRZhaNaMXyZouX50Fl6QTZBvFjpfeeuKu2wpmUQhV8nB4eeQ=
	=
X-Received: by 2002:a02:8a4a:: with SMTP id e10mr3425033jal.120.1552363141674;
        Mon, 11 Mar 2019 20:59:01 -0700 (PDT)
X-Received: by 2002:a02:8a4a:: with SMTP id e10mr3425000jal.120.1552363140706;
        Mon, 11 Mar 2019 20:59:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552363140; cv=none;
        d=google.com; s=arc-20160816;
        b=OidpNbIFTEdh9z3fBkPD11ICVSPTfg83LF1HX1MsZzdy93fSaJ/a41bMno0eL3Oju8
         75NJ1jBQ/otbGo2p3w8KiTsG2qnxh7uqWSyGwkSayOtaUvfPWFWNlTMLWOdQgxSCb6Cp
         33eYvkIVQECTC0sYvJB363MLf8Ob/GzcarA5u1Bq7+qmcqBDJkYdw493LB8pY1YvlHA2
         otTwzEFTY9TwBFThpric/R4ZbrQOKe1MRDuoczUiJCSdkUNkhlHG43rIMcFTADrfow9c
         f7TIhTsY6YAmEYHmeDFMjIkn0+L0FzKXjXpoTljjYJpk/NpBOZq7O4VKeZ2qNce0bjFK
         usKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=Rg1C2aX0HyUdcFpVwU4EWVeEJy42p9kXBaO9Wh8/VOs=;
        b=XyPlHz86rXBwOQxzG63atjVaRNtjRCLTLQE/DWUrX0ZKHWHFuOWC3A5WT5npAk7jXF
         /631zD3gks09c+V7orQCaXx8Qw0mWGEJhwGmt1HJCfv0GEYJiYYC1zvAsaCU2cS1hBpM
         C95OPSzD1KZ/wt0PkcuLjNpgk+TVJS6HCqXo5akxutmChdhGsQcbv+yLaooEB8FwDUnb
         gd7lQgFzduiFVaJvPsNWqxDKvTVO4MS4tzB5MUPFon3ZwPknEiF8RWcxDggs/fNFZvgf
         bsIiDLJVGkppa06eTHRPKvRDVYHu0Ym/mLf0ahobTuh2n+SiE7DlwSpb9BJc4hWe6F0R
         fryA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3hc6hxakbaocbhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3hC6HXAkbAOcbhiTJUUNaJYYRM.PXXPUNdbNaLXWcNWc.LXV@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id a184sor1791054itc.31.2019.03.11.20.59.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 20:59:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3hc6hxakbaocbhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3hc6hxakbaocbhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3hC6HXAkbAOcbhiTJUUNaJYYRM.PXXPUNdbNaLXWcNWc.LXV@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqwx9h7KDCPuvh+6fEd+XQtf2O1zRoUBFtwZYLOb127vefqqt6zi0UA2Qkz2LYFWcqyT1Fnl/+4tGtcpRf0Lowm6YM5gcQBt
MIME-Version: 1.0
X-Received: by 2002:a24:6283:: with SMTP id d125mr833066itc.14.1552363140443;
 Mon, 11 Mar 2019 20:59:00 -0700 (PDT)
Date: Mon, 11 Mar 2019 20:59:00 -0700
In-Reply-To: <00000000000010b2fc057fcdfaba@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000008c75b50583ddb5f8@google.com>
Subject: Re: INFO: rcu detected stall in sys_sendfile64 (2)
From: syzbot <syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com>
To: airlied@linux.ie, akpm@linux-foundation.org, amir73il@gmail.com, 
	chris@chris-wilson.co.uk, darrick.wong@oracle.com, david@fromorbit.com, 
	dri-devel@lists.freedesktop.org, dvyukov@google.com, eparis@redhat.com, 
	hannes@cmpxchg.org, hughd@google.com, intel-gfx@lists.freedesktop.org, 
	jack@suse.cz, jani.nikula@linux.intel.com, joonas.lahtinen@linux.intel.com, 
	jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	mingo@redhat.com, mszeredi@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, 
	peterz@infradead.org, rodrigo.vivi@intel.com, syzkaller-bugs@googlegroups.com, 
	viro@zeniv.linux.org.uk, willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit 34e07e42c55aeaa78e93b057a6664e2ecde3fadb
Author: Chris Wilson <chris@chris-wilson.co.uk>
Date:   Thu Feb 8 10:54:48 2018 +0000

     drm/i915: Add missing kerneldoc for 'ent' in i915_driver_init_early

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=13220283200000
start commit:   34e07e42 drm/i915: Add missing kerneldoc for 'ent' in i915..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=10a20283200000
console output: https://syzkaller.appspot.com/x/log.txt?x=17220283200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=abc3dc9b7a900258
dashboard link: https://syzkaller.appspot.com/bug?extid=1505c80c74256c6118a5
userspace arch: amd64
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12c4dc28c00000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15df4108c00000

Reported-by: syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com
Fixes: 34e07e42 ("drm/i915: Add missing kerneldoc for 'ent' in  
i915_driver_init_early")

