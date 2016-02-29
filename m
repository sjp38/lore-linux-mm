Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B594F6B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 00:01:52 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 124so23880169pfg.0
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 21:01:52 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id z7si3996431par.63.2016.02.28.21.01.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 21:01:51 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id fl4so85354887pad.0
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 21:01:51 -0800 (PST)
Subject: Re: [LSF/MM ATTEND][LSF/MM TOPIC] Address range mirroring enhancement
References: <E86EADE93E2D054CBCD4E708C38D364A734D7A73@G01JPEXMBYT01>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <56D3D0BA.6040209@gmail.com>
Date: Mon, 29 Feb 2016 16:01:46 +1100
MIME-Version: 1.0
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A734D7A73@G01JPEXMBYT01>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Tony Luck <tony.luck@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>


On 29/02/16 13:12, Izumi, Taku wrote:
> Hi,
>
> I'd like to atten LSF/MM 2016 and I'd like to discuss "Address range mirroring" topic.
> The current status of Address range mirroring in Linux is:
>   - bootmem will be allocated from mirroring range
>   - kernel memorry will be allocated from mirroring range 
>     by specifying kernelcore=mirror 
>
> I think we can enhance Adderss range mirroring more.
> For excample,
>   - The handling of mirrored memory exhaustion case
>   - The option any user memory can be allocated from mirrored memory
>   and so on.
>
> I'd like to discuss this topic.
>
>

Sounds interesting! Do you have a detailed write up on the topic?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
