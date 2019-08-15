Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B29C9C433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 01:26:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EFEA2084F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 01:26:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EFEA2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C749F6B0003; Wed, 14 Aug 2019 21:26:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C268C6B0005; Wed, 14 Aug 2019 21:26:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3A4A6B0007; Wed, 14 Aug 2019 21:26:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFA36B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:26:02 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 355EC181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 01:26:02 +0000 (UTC)
X-FDA: 75822920964.05.word80_34a8b96f97d16
X-HE-Tag: word80_34a8b96f97d16
X-Filterd-Recvd-Size: 3044
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 01:26:01 +0000 (UTC)
Received: by mail-oi1-f199.google.com with SMTP id d12so9675oic.10
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:26:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:date:in-reply-to:message-id:subject
         :from:to;
        bh=ttLtpKYMG7TZIiRY6rerl+aSlij3EK8LczMw+lIahls=;
        b=J7S/1AKCUWeO6r+gUFp8nmzFaVPzmsdC6teXSfUt7zPVaHDHlEqU7EDIevILTnpwxZ
         +MIXzx55L81P7qkleSQxCVIbWzMURKjX5LiJQJql78hDBHP8WW1nV0T/W+8dETCISJt/
         bGVe+Hqk0KHOHXDdZ2Wkusr4VMfwioMlaN8c4HJDSIeN4iCUuIwzctDJjYPNFAShXR7p
         ql/UzHpcmyt2/jmVgVJtecWYEKzb3TAehZvYEETro4ErqeKfybg3brLPuIT85V2H0BPv
         YCzaMsgzp/1RD+be81qkGmkWO9jxEkeHY4vdmE53vPhT5Dj/cWkyK8mNQ50xcRhJdC8P
         p5Fw==
X-Gm-Message-State: APjAAAWJoO7yI/eGv0HH5ZPThbPgKAZ1ZG95Z1sW7jWoAPFQZjjgi8R6
	I0lvNvJt5GjQwpBRmOmdmEZ62lnFgA65HFH1UF56ohiaE8Bc
X-Google-Smtp-Source: APXvYqytQ/ELGP5+AJ2kRvyfVtkrEdnSzCYc+HmAHVK4EP5we3PzXTOJnMwkWDWnNNMXNALxzIO9aa+V7C7O9SGIfcOtTSnNTuWC
MIME-Version: 1.0
X-Received: by 2002:a6b:dd18:: with SMTP id f24mr2888565ioc.97.1565832361042;
 Wed, 14 Aug 2019 18:26:01 -0700 (PDT)
Date: Wed, 14 Aug 2019 18:26:01 -0700
In-Reply-To: <000000000000b851cb058f7e637f@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000a86cf005901dc156@google.com>
Subject: Re: WARNING in cgroup_rstat_updated
From: syzbot <syzbot+370e4739fa489334a4ef@syzkaller.appspotmail.com>
To: ast@kernel.org, daniel@iogearbox.net, hdanton@sina.com, 
	john.fastabend@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	netdev@vger.kernel.org, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000263, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit e9db4ef6bf4ca9894bb324c76e01b8f1a16b2650
Author: John Fastabend <john.fastabend@gmail.com>
Date:   Sat Jun 30 13:17:47 2018 +0000

     bpf: sockhash fix omitted bucket lock in sock_close

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=143286e2600000
start commit:   31cc088a Merge tag 'drm-next-2019-07-19' of git://anongit...
git tree:       net-next
final crash:    https://syzkaller.appspot.com/x/report.txt?x=163286e2600000
console output: https://syzkaller.appspot.com/x/log.txt?x=123286e2600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4dba67bf8b8c9ad7
dashboard link: https://syzkaller.appspot.com/bug?extid=370e4739fa489334a4ef
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16dd57dc600000

Reported-by: syzbot+370e4739fa489334a4ef@syzkaller.appspotmail.com
Fixes: e9db4ef6bf4c ("bpf: sockhash fix omitted bucket lock in sock_close")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection

