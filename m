Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0434C43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 04:43:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B84E20651
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 04:43:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B84E20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E66E88E0003; Mon, 14 Jan 2019 23:43:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E159F8E0002; Mon, 14 Jan 2019 23:43:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D061E8E0003; Mon, 14 Jan 2019 23:43:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id A826E8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 23:43:04 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id v188so1705827ita.0
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 20:43:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to:content-transfer-encoding;
        bh=+ZN2k/FAzbBiH8bFl9sH6z6FpVTp2oha0mwreEMwqrA=;
        b=rWGol3Pl/6xPl+wILgWLT7tz4AP6uVIQwfpS3ipGshO6/AxQ4GAJt3n2IGBGDI3q1K
         xAlrgLBu1FGqWLEvUZSFPGnzw7KoKqPs3MlLBOWwWmdjI78KiaYIlFDDrjw/VqCyxO0H
         4jzX8fwrezWnR4PSQXiQ5X1kzTwwxJmCOOhZKGzRWmOW1k2RYWs4sD+SDctDr9aqrm0E
         2RtFG1fDVVJYhroELTdm9BMI2GF5I0ThIebDXzsJz5td5nTXUpM0+aX7YdZzUpWezqLi
         c4IZ9S3U18rxmW9zhKJlZ9FF9FNyQ5kUhV6YHChBunrXh+2o51G65XcOan/pq1TQewBl
         yorg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 312q9xakbah4u01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=312Q9XAkbAH4u01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUuke60It85rsrNeSvmV0mGkvGD/1peZ7e+c+YfK6WA5n0t+frbIqf
	vN6GfYqPNpNE2ych7tzJxmDsxwGmgI6fiMehi2T2Xnovs836AcRe8DBdf1ZSQ6BQvquoU0QYick
	hHHenetWriDm30oXT9rB3A16dIjub6MBijZkWEiIROiH0KVsXcjWXLvlfsfqe5SDtcWoFpc9Sh/
	LdWLQRmUtR8jy2q2crBrYdOUdT31wtwMaWJn+/u2EMxx6VpcJXNx5PhTVsigBrGqICHCrcxbiVu
	BJsj9hOxidrmBn8Mz5LLjkqB5iNPVgilwi4DT9aBSVEIlgIpll5F4Hl/B6+9WAYYIz7Flo7bxsU
	hQwqFcqGbykQWC7DQCxaGFKYYDKAe42Q5VTOdnN477FV8ddS/4ayVMu0VpLtZLM3Fm1x+OoYdg=
	=
X-Received: by 2002:a6b:3809:: with SMTP id f9mr1050983ioa.305.1547527384341;
        Mon, 14 Jan 2019 20:43:04 -0800 (PST)
X-Received: by 2002:a6b:3809:: with SMTP id f9mr1050970ioa.305.1547527383566;
        Mon, 14 Jan 2019 20:43:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547527383; cv=none;
        d=google.com; s=arc-20160816;
        b=epvwF3eT4gGUVzn07Z59cn+nouNXr1eIdixHeD3XzM0VHIuBlj0XL0zhBymWM5aUX6
         M29hyUX5mUh7rIEkOESwzVZXnl15PjHXtviLNVZHkbiGJgl2wIA9qsRVI/GXEG748tLK
         wLJ7ohF+uLkJu6et4SSmn7Wa6xvEC4mjoDkDcuYJvOKPEkinps+xkFmUGGVqHgX98ban
         LTHGKYDBOQpk3CLfK1TJQK/R0e8y4Vj7kfx5kfWj3ZcdIK6XUFsaeVHpSlmsXyD6N2dK
         PPexPmORRmD/vM+Ie8IHmC/zXJb/R/GQkhPOFd5cLXeERwOzebG9jDb4FY2AM2sQT9YQ
         Nybw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:to:from:subject:message-id:date
         :mime-version;
        bh=+ZN2k/FAzbBiH8bFl9sH6z6FpVTp2oha0mwreEMwqrA=;
        b=XMWFmJsc92OKM8P8jUvnaoK7nr86RKNvcFbbYjbMs4/P4xNgIQq06gteQ4oFOVNnZ7
         7BMQNVJ9zUbPZJKjO4GIu+l6MM7ZjwR+P3iP11mdJk065TJFTSTvvA++dEQWqRoGyRRW
         2CEN7RmJwrqIMg2e/87xj1Kn+3MPSqEhCmNvXKxJpUAJmTdl1YO75XwtjV0cRfWpEbRT
         iJSf3z2Bvsu4bq0GXCmF9Op8RYWfB4QiQ/b9HdZEtJ4jApThnMW0B97Av0dWcQGWaUy7
         56O92n5d95QI5R3QxGmE3WSNVgQNt7CSLSsCAGN5kfm9YIgnpymyLlz5eXmbf3mfGIt9
         rr1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 312q9xakbah4u01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=312Q9XAkbAH4u01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id y7sor1182722ioa.135.2019.01.14.20.43.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 20:43:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 312q9xakbah4u01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 312q9xakbah4u01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=312Q9XAkbAH4u01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN5IJ8jBC/pJ7LLxE8gvsIqAvivcDUoZPQNVLC3bMdmo9hsIUszlSm+1zKbyLpjO6IZ6O46ya5d0nk8RUY4iucPnWKjgYVqN
MIME-Version: 1.0
X-Received: by 2002:a6b:680a:: with SMTP id d10mr1058562ioc.35.1547527383190;
 Mon, 14 Jan 2019 20:43:03 -0800 (PST)
Date: Mon, 14 Jan 2019 20:43:03 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000f49537057f77cb00@google.com>
Subject: KASAN: use-after-scope Read in corrupted
From: syzbot <syzbot+bd36b7dd9330f67037ab@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, cai@lca.pw, crecklin@redhat.com, 
	keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
Content-Transfer-Encoding: base64
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115044303.Jt6JGb3KFN7xL4OW95r3zEWvVXLGggC7ZX93_pyNCIg@z>

SGVsbG8sDQoNCnN5emJvdCBmb3VuZCB0aGUgZm9sbG93aW5nIGNyYXNoIG9uOg0KDQpIRUFEIGNv
bW1pdDogICAgMWJkYmUyMjc0OTIwIE1lcmdlIHRhZyAndmZpby12NS4wLXJjMicgb2YgZ2l0Oi8v
Z2l0aHViLmNvbS4uDQpnaXQgdHJlZTogICAgICAgdXBzdHJlYW0NCmNvbnNvbGUgb3V0cHV0OiBo
dHRwczovL3N5emthbGxlci5hcHBzcG90LmNvbS94L2xvZy50eHQ/eD0xNTE5ZDM5ZjQwMDAwMA0K
a2VybmVsIGNvbmZpZzogIGh0dHBzOi8vc3l6a2FsbGVyLmFwcHNwb3QuY29tL3gvLmNvbmZpZz94
PWVkZjFjMzAzMTA5N2MzMDQNCmRhc2hib2FyZCBsaW5rOiBodHRwczovL3N5emthbGxlci5hcHBz
cG90LmNvbS9idWc/ZXh0aWQ9YmQzNmI3ZGQ5MzMwZjY3MDM3YWINCmNvbXBpbGVyOiAgICAgICBn
Y2MgKEdDQykgOS4wLjAgMjAxODEyMzEgKGV4cGVyaW1lbnRhbCkNCnN5eiByZXBybzogICAgICBo
dHRwczovL3N5emthbGxlci5hcHBzcG90LmNvbS94L3JlcHJvLnN5ej94PTEwZmNlMTRmNDAwMDAw
DQpDIHJlcHJvZHVjZXI6ICAgaHR0cHM6Ly9zeXprYWxsZXIuYXBwc3BvdC5jb20veC9yZXByby5j
P3g9MTEwYjIwMTc0MDAwMDANCg0KSU1QT1JUQU5UOiBpZiB5b3UgZml4IHRoZSBidWcsIHBsZWFz
ZSBhZGQgdGhlIGZvbGxvd2luZyB0YWcgdG8gdGhlIGNvbW1pdDoNClJlcG9ydGVkLWJ5OiBzeXpi
b3QrYmQzNmI3ZGQ5MzMwZjY3MDM3YWJAc3l6a2FsbGVyLmFwcHNwb3RtYWlsLmNvbQ0KDQo9PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT0NCkJVRzogS0FTQU46IHVzZS1hZnRlci1zY29wZSBpbiBkZWJ1Z19sb2NrZGVwX3JjdV9l
bmFibGVkLnBhcnQuMCsweDUwLzB4NjAgIA0Ka2VybmVsL3JjdS91cGRhdGUuYzoyNDkNClJlYWQg
b2Ygc2l6ZSA0IGF0IGFkZHIgZmZmZjg4ODBhOTQ1ZWFiYyBieSB0YXNrICANCmA577+977+977+9
77+977+977+9I++/vSgVEO+/ve+/ve+/ve+/ve+/vTzvv73vv73vv73vv73vv70QGmvvv73vv73v
v73vv73vv73vv73vv71F77+977+977+977+977+9Pjlo77+977+977+977+977+977+977+977+9
QS8tMjEyMjE4ODYzNA0KDQpDUFU6IDAgUElEOiAtMjEyMjE4ODYzNCBDb21tOiDvv73vv71F77+9
77+977+977+977+977+977+977+977+977+977+977+977+9TzLvv70gTm90IHRhaW50ZWQgNS4w
LjAtcmMxKyAgDQojMTkNCkhhcmR3YXJlIG5hbWU6IEdvb2dsZSBHb29nbGUgQ29tcHV0ZSBFbmdp
bmUvR29vZ2xlIENvbXB1dGUgRW5naW5lLCBCSU9TICANCkdvb2dsZSAwMS8wMS8yMDExDQotLS0t
LS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0NCkJhZCBvciBtaXNzaW5nIHVzZXJjb3B5
IHdoaXRlbGlzdD8gS2VybmVsIG1lbW9yeSBvdmVyd3JpdGUgYXR0ZW1wdCBkZXRlY3RlZCAgDQp0
byBTTEFCIG9iamVjdCAndGFza19zdHJ1Y3QnIChvZmZzZXQgMTM0NCwgc2l6ZSA4KSENCldBUk5J
Tkc6IENQVTogMCBQSUQ6IC0xNDU1MDM2Mjg4IGF0IG1tL3VzZXJjb3B5LmM6NzggIA0KdXNlcmNv
cHlfd2FybisweGViLzB4MTEwIG1tL3VzZXJjb3B5LmM6NzgNCktlcm5lbCBwYW5pYyAtIG5vdCBz
eW5jaW5nOiBwYW5pY19vbl93YXJuIHNldCAuLi4NCkNQVTogMCBQSUQ6IC0xNDU1MDM2Mjg4IENv
bW06IO+/ve+/vUXvv73vv73vv73vv73vv73vv73vv73vv73vv73vv73vv73vv73vv71PMu+/vSBO
b3QgdGFpbnRlZCA1LjAuMC1yYzErICANCiMxOQ0KSGFyZHdhcmUgbmFtZTogR29vZ2xlIEdvb2ds
ZSBDb21wdXRlIEVuZ2luZS9Hb29nbGUgQ29tcHV0ZSBFbmdpbmUsIEJJT1MgIA0KR29vZ2xlIDAx
LzAxLzIwMTENCkNhbGwgVHJhY2U6DQpLZXJuZWwgT2Zmc2V0OiBkaXNhYmxlZA0KUmVib290aW5n
IGluIDg2NDAwIHNlY29uZHMuLg0KDQoNCi0tLQ0KVGhpcyBidWcgaXMgZ2VuZXJhdGVkIGJ5IGEg
Ym90LiBJdCBtYXkgY29udGFpbiBlcnJvcnMuDQpTZWUgaHR0cHM6Ly9nb28uZ2wvdHBzbUVKIGZv
ciBtb3JlIGluZm9ybWF0aW9uIGFib3V0IHN5emJvdC4NCnN5emJvdCBlbmdpbmVlcnMgY2FuIGJl
IHJlYWNoZWQgYXQgc3l6a2FsbGVyQGdvb2dsZWdyb3Vwcy5jb20uDQoNCnN5emJvdCB3aWxsIGtl
ZXAgdHJhY2sgb2YgdGhpcyBidWcgcmVwb3J0LiBTZWU6DQpodHRwczovL2dvby5nbC90cHNtRUoj
YnVnLXN0YXR1cy10cmFja2luZyBmb3IgaG93IHRvIGNvbW11bmljYXRlIHdpdGggIA0Kc3l6Ym90
Lg0Kc3l6Ym90IGNhbiB0ZXN0IHBhdGNoZXMgZm9yIHRoaXMgYnVnLCBmb3IgZGV0YWlscyBzZWU6
DQpodHRwczovL2dvby5nbC90cHNtRUojdGVzdGluZy1wYXRjaGVzDQo=

