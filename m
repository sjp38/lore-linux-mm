Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id F17EB6B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 21:12:56 -0500 (EST)
Received: by mail-io0-f171.google.com with SMTP id g203so172719460iof.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 18:12:56 -0800 (PST)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id vv11si15316484igb.55.2016.02.28.18.12.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 18:12:56 -0800 (PST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 2AA78AC00E4
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 11:12:51 +0900 (JST)
From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: [LSF/MM ATTEND][LSF/MM TOPIC] Address range mirroring enhancement
Date: Mon, 29 Feb 2016 02:12:49 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A734D7A73@G01JPEXMBYT01>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Tony Luck <tony.luck@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>

Hi,

I'd like to atten LSF/MM 2016 and I'd like to discuss "Address range mirroring" topic.
The current status of Address range mirroring in Linux is:
  - bootmem will be allocated from mirroring range
  - kernel memorry will be allocated from mirroring range 
    by specifying kernelcore=mirror 

I think we can enhance Adderss range mirroring more.
For excample,
  - The handling of mirrored memory exhaustion case
  - The option any user memory can be allocated from mirrored memory
  and so on.

I'd like to discuss this topic.

Sincerely,
Taku Izumi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
