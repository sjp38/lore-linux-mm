Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06A13C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 15:03:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6BF92175B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 15:03:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="LdLRlayh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6BF92175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 518308E0003; Tue, 29 Jan 2019 10:03:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C5E18E0001; Tue, 29 Jan 2019 10:03:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38FD28E0003; Tue, 29 Jan 2019 10:03:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0AEF8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:03:42 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id f193so5931304wme.8
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 07:03:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=54BYA5R8WWU/JT6uen3I6PSN41rOBysT9ibhJ3C66mE=;
        b=E5ztBqo3MYgWseog4FYGAGcKIWa3vFLLHseVXUEahgOdpptx3ky0a7IBCEbljfmmNY
         1dlL6BcRapGWb5Ij7dGL5sPyKlO+kH4yyPCOHu+7Fu5vrPmFuf4jdwD0EbBLBA7W2WA9
         86qCLzzEWb42jgFaJxb1iQEOu0BD6ieQAKoQh7UqPqZ4ULOLVq/Muy8S5xyAPq8ht9NH
         iHQThEsb206hJj2ErlgmrrQHmfwr3qX8avJWBRYAgzKM3nrKoKzEz5PurvjmbrP5BA9c
         pgmVYfduS4GQ3C2L5Sw43t5WR9/0x8HoGtQROFjAC89A05lX4ox1X/0wa43ceAt8AhP5
         RKkw==
X-Gm-Message-State: AJcUukePuNR5xnFsg2w8UutY0lJmkcoYwZ4njQiIixgAblbEtc35/jpu
	sEAlivtySiqE/YApRO2dTs7tKAusv6Nsj1WmYPqlV9+wnODDSawX2ivM3adm1sn8eYvWkuq0UG1
	BkCeeSVBz8sUlxq1zxyQt2WQsBRuH0CF7CDxXKJq6tCI9CyrvgsGCcgGQBz5e7q/1fg==
X-Received: by 2002:adf:eb45:: with SMTP id u5mr25204871wrn.102.1548774222166;
        Tue, 29 Jan 2019 07:03:42 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6GTxW4eQqCJyb+qwQXzQc3JwrnK822aZDg8yB77ouPHO5CqHH12IpZIH13ZRmHFjtl3Wz5
X-Received: by 2002:adf:eb45:: with SMTP id u5mr25204820wrn.102.1548774221169;
        Tue, 29 Jan 2019 07:03:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548774221; cv=none;
        d=google.com; s=arc-20160816;
        b=NMuAt1d33DqO/xmRJIq2BZglzYWPdT3PaoJ1qJNOTv+q4brbewm3+EvPQd/ZhZcbuY
         RTIa+5jBJ+zrtMujl0c2ul4hGycotbNcM2f50/bFCQ23IJuwCYPjFldIZgwjrw0+aYz9
         b+IGF/KGjkTn0c0GJ7KyDOrjLwpqEKO9NNOB3N4o6b49dRv15Uw5CyXbXoz3T2s3T6MD
         ARNgyqozLa3XkI3MkgZZZn9fYRub+uUPJg+1l7nU/cXyHz2Fc4owteF2ZSnUjkCAfhAt
         oJxFOkfbrs4IXVP4IGummyImju5Fw3SFUgzTLyUp5Vui+NrcaNgl9zCspetTv+BnYlI2
         uFYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=54BYA5R8WWU/JT6uen3I6PSN41rOBysT9ibhJ3C66mE=;
        b=eDpJOJJVZPgCGvGqZ0BSxUypCH8o5BPs3hdaV2OVMQlHay202dwffuojyn3q3ZBvgG
         LNfq6ts1wz+w1BokVJ0u54FvTz9aKX5qCWXQaUL0440mUq60NyFY8FTnNo73KskYFgpu
         RXmw/a+GuasY9yBxls0r/0xy5u7J4jHRz2AXaxolWo6tnpdU+z1QheObbOtMOkrttjBB
         iXeQJ59xHYtWl311CpQ8BWq/aIBYr12OKxa9yCrs3bDzW9Ao0FNTk9oog/6B1l2yTafh
         ujVK8xy/0Rt8/qys+U0jIUvkGqppKTdd9B6qX5LNTYSH/+x3yqL/qsEjX6ap/SjxfL6d
         xaaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=LdLRlayh;
       spf=neutral (google.com: 2a01:238:20a:202:5302::2 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p02-ob.smtp.rzone.de (mo6-p02-ob.smtp.rzone.de. [2a01:238:20a:202:5302::2])
        by mx.google.com with ESMTPS id r82si2068261wma.110.2019.01.29.07.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 07:03:41 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5302::2 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5302::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=LdLRlayh;
       spf=neutral (google.com: 2a01:238:20a:202:5302::2 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1548774220;
	s=strato-dkim-0002; d=xenosoft.de;
	h=In-Reply-To:Date:Message-ID:References:Cc:To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=54BYA5R8WWU/JT6uen3I6PSN41rOBysT9ibhJ3C66mE=;
	b=LdLRlayhsFbav89sj8ND3JJdmEsC0/VzcSqvzQa1cNgTWr8h0SA2Yt5UsUTdkc7aYS
	HegLu0aGm6GFOXK/pcceeiwWAo+zW/ZamoKPeXlFDF6RTJK943SONvaSXUD02KIxTXm2
	499l5MJbPX2yPC8oiNzpU754e7/+1blZvG1bvvnKqEHXM3zOIXX2VUV4QHg4bl2BT6YX
	dPFQa5uGJZgh4mqKEYqNLk3MKPN+TAmd76DAkaEYp5XLq9x2BaCozIo9c9OM39pAL0c7
	wpuCBD8AbJqSNf2x5pBQGmeDjfVAR7QH+gscWXSOHIRjl5uP1aTd5DzDGPld7pimNR0c
	fRwQ==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGM4l4Hio94KKxRySfLxnHfJ+Dkjp5G5MdirQj0WG7CkMj7d8MwbIAsOkSwoB8cVrNHNchA=="
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:31f7:8c35:dc40:528c]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv0TF3XAMu
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Tue, 29 Jan 2019 16:03:33 +0100 (CET)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
References: <e11e61b1-6468-122e-fc2b-3b3f857186bb@xenosoft.de>
 <f39d4fc6-7e4e-9132-c03f-59f1b52260e0@xenosoft.de>
 <b9e5e081-a3cc-2625-4e08-2d55c2ba224b@xenosoft.de>
 <20190119130222.GA24346@lst.de> <20190119140452.GA25198@lst.de>
 <bfe4adcc-01c1-7b46-f40a-8e020ff77f58@xenosoft.de>
 <8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de>
 <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de>
 <1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de>
 <20190128070422.GA2772@lst.de> <20190128162256.GA11737@lst.de>
 <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de>
Message-ID: <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de>
Date: Tue, 29 Jan 2019 16:03:32 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

I compiled kernels for the X5000 and X1000 from your new branch 
'powerpc-dma.6-debug.2' today. The kernels boot and the P.A. Semi 
Ethernet works!

Cheers,
Christian


On 28 January 2019 at 5:52PM, Christian Zigotzky wrote:
> Thanks a lot! I will test it tomorrow.
>
> — Christian
>
> Sent from my iPhone
>
>> On 28. Jan 2019, at 17:22, Christoph Hellwig <hch@lst.de> wrote:
>>
>>> On Mon, Jan 28, 2019 at 08:04:22AM +0100, Christoph Hellwig wrote:
>>>> On Sun, Jan 27, 2019 at 02:13:09PM +0100, Christian Zigotzky wrote:
>>>> Christoph,
>>>>
>>>> What shall I do next?
>>> I'll need to figure out what went wrong with the new zone selection
>>> on powerpc and give you another branch to test.
>> Can you try the new powerpc-dma.6-debug.2 branch:
>>
>>     git://git.infradead.org/users/hch/misc.git powerpc-dma.6-debug.2
>>
>> Gitweb:
>>
>>     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6-debug.2
>

