Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 540756B0009
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 00:31:33 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id z8so35053402ige.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 21:31:33 -0800 (PST)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id n14si24045473ioe.193.2016.03.01.21.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 21:31:32 -0800 (PST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id AEAEEAC030D
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 14:31:24 +0900 (JST)
From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [LSF/MM ATTEND][LSF/MM TOPIC] Address range mirroring
 enhancement
Date: Wed, 2 Mar 2016 05:31:23 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A734D9220@G01JPEXMBYT01>
References: <E86EADE93E2D054CBCD4E708C38D364A734D7A73@G01JPEXMBYT01>
 <56D3D0BA.6040209@gmail.com>
In-Reply-To: <56D3D0BA.6040209@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Tony Luck <tony.luck@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> > Hi,
> >
> > I'd like to atten LSF/MM 2016 and I'd like to discuss "Address range mirroring" topic.
> > The current status of Address range mirroring in Linux is:
> >   - bootmem will be allocated from mirroring range
> >   - kernel memorry will be allocated from mirroring range
> >     by specifying kernelcore=mirror
> >
> > I think we can enhance Adderss range mirroring more.
> > For excample,
> >   - The handling of mirrored memory exhaustion case
> >   - The option any user memory can be allocated from mirrored memory
> >   and so on.
> >
> > I'd like to discuss this topic.
> >
> >
> 
> Sounds interesting! Do you have a detailed write up on the topic?

  Give me some time to make a detailed write up.

  Former discussions are:
   http://thread.gmane.org/gmane.linux.kernel/1884223
   https://lkml.org/lkml/2015/6/4/359
   http://www.mail-archive.com/linux-kernel%40vger.kernel.org/msg992524.html
   http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg997069.html
   https://lkml.org/lkml/2015/11/27/18
   https://lkml.org/lkml/2015/12/8/836

 Sincerely,
 Taku Izumi

> 
> Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
