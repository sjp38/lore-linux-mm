Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48D9FC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 19:50:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02F9F222C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 19:50:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="PZTm9hlu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02F9F222C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8876F8E0002; Tue, 12 Feb 2019 14:50:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8352F8E0001; Tue, 12 Feb 2019 14:50:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FD698E0002; Tue, 12 Feb 2019 14:50:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 188288E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 14:50:30 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id z16so1411592wrt.5
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:50:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=aUXr1fGv9JuKgZ63EUrQVCOsJ7eDcmZXM8Fg+HWeyds=;
        b=OHgeCVQf6iE90v0tIO+nejpnlsAyNdX0XX3IVzYHRO/RO7STdb0+YVeVWNyvbqJPm/
         7f+blId3kV93b0sT/OKtimDF5xAmfOsCNhklBt6t4+K7m/RkuDq1OzY/Tr+tSMSpZy0W
         2dqZbgio0AD+vZ6Tdu3kdEkvazWIGyJVW2/wFLsjfrlLkIGHy0YgMByZVvPu2JzrImC8
         ognpgm8dhqeq941KgpV97YiAXGrSMnrepRHDg2NEzT18K488PFy50yENj0txVjdRoMSf
         qp5YLkMFJKznngzDB4EvtVBDvZ65F4tnNLTVEKLin16TAUXKlJ5sFZlwhUuCmucbEzBF
         KnEw==
X-Gm-Message-State: AHQUAub/Wt6XOlKqiHgTz/UI64rVSsImPtV+Azj96JaLYOH1ynyqiFJq
	TtUmk3yq/gY8BH8oLou+HHUqp5CXDjUv2w3KOkSdld1F559bLZsSNMRODcKh3w0w0bLEUIxEXM2
	GGdFnpCKjiXotUyyuC6+hJm3s7f1yb8ORZXw452kHcEDpakqdM8P0SxZzMP6Pf0l9XA==
X-Received: by 2002:a7b:c04f:: with SMTP id u15mr378776wmc.49.1550001029469;
        Tue, 12 Feb 2019 11:50:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaCBJ+vyrzzIgYZEL5lGUqFhD7K9CzDG3YsS3n++QNlGS9pvERy/BxpdLisp6ym/1+f+XIG
X-Received: by 2002:a7b:c04f:: with SMTP id u15mr378744wmc.49.1550001028452;
        Tue, 12 Feb 2019 11:50:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550001028; cv=none;
        d=google.com; s=arc-20160816;
        b=AFMdCvQ15SQcU5BppPLnGIS0H6r/oe7Mo/edr+azL0ArMgg5TxKGfcpssQCXXODFub
         8WEtICNc2q0D6YwcPnIdetu1bzJPVA4S3jiBDj72fv1WKKPJ50dt/xCqFd+1S5Liigs+
         wTx7hm1nWMozbFxcqn6IY5ksGNq3ggyr2Zn86MEaK2QDfG9xvvwXykCH+L2QeyCCmdoM
         Rz+YgUXAlhswUEptZJ6UQ5E0Zh/75BKEVygWciLyFtUEN18yWBCqL+cSCQUQAZEXgD/D
         47FqVXVNqI/AMMINOFncPv6iZxqpxoSKwMNbPu1tzghtCHFvaEJdwxh2zP/rPN5c+DGx
         mxkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=aUXr1fGv9JuKgZ63EUrQVCOsJ7eDcmZXM8Fg+HWeyds=;
        b=bebigAPmjjVGC6w+iIzVSXfxFaDnBDbLkMAJFybEGcXW/K7aGJOaxeioV7uZYs2uFl
         McjUedkUpVNngw9rSbii+ypmZ309t3lDVbQxh6xXzwNo0Rg/yRDODp7tkiBnU+JYVrzN
         0W06i4+7AzXZvSVcar+uPEjfVcTJn2tzBLR65tId1EZh5TZ2UpGod2PKkHaiSHnkaC45
         Rm/qlFzc2VpIyuKMsQ8LADdXwgAvr87ndZId753/t2v6uO//eW+oidvG/Paj2t8CRz1S
         3vUyfMJBLhFmbLcaTfozmSPqxRR5ryvMhg/C0X3YVvFxNhrVBhYTqTj5lpTrdfMENUiC
         d6pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=PZTm9hlu;
       spf=neutral (google.com: 2a01:238:20a:202:5302::8 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p02-ob.smtp.rzone.de (mo6-p02-ob.smtp.rzone.de. [2a01:238:20a:202:5302::8])
        by mx.google.com with ESMTPS id a203si2383963wmh.55.2019.02.12.11.50.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 11:50:28 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5302::8 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5302::8;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=PZTm9hlu;
       spf=neutral (google.com: 2a01:238:20a:202:5302::8 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1550001028;
	s=strato-dkim-0002; d=xenosoft.de;
	h=In-Reply-To:Date:Message-ID:References:Cc:To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=aUXr1fGv9JuKgZ63EUrQVCOsJ7eDcmZXM8Fg+HWeyds=;
	b=PZTm9hluR/ZMMNJuGVck5xB8O2hHWXAEr3/4JWObgFxQeD49DLDCriT5BgBEft226C
	xarXTfAE8EtgDqZRoiFcrYSbf0fRzPtRwp2obwvxe6TfBWO/87YnpVzdHOQ+v1f+cKN4
	6Yf5VS1CAVFpLTUVbECaihHKdQ0iwL3u6VKQURD/a+pAVqZ+3itR4SHTX0/+uqco41We
	3yLYulm/7fDwCJLrVRNU2iZaxmkHPnDoNCVEYJjNFOH8WcPxfqo2LCWs4pHxRkJUg2Mi
	zuSbVt092MiPoU4rIKSF5GujanlGPBquiWxMbxyhUEnW48ZAp2fR6dbzFPov2d2EUVIE
	VUCQ==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGM4l4Hio94KKxRySfLxnHfJ+Dkjp5G5MdirQj0WG7CldjiKRzWNYwK19ivDpIsfNmMN15w=="
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:b071:4d43:dec6:a483]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv1CJoKRyh
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Tue, 12 Feb 2019 20:50:20 +0100 (CET)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
References: <20190204123852.GA10428@lst.de>
 <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de>
 <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de>
 <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de>
 <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de>
 <20190208091818.GA23491@lst.de>
 <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de>
 <20190211073804.GA15841@lst.de>
 <820bfeb1-30c0-3d5a-54a2-c4f9a8c15b0e@xenosoft.de>
 <20190212152543.GA24061@lst.de>
 <47bff9d1-7001-4d92-4ad1-e24215b56555@xenosoft.de>
Message-ID: <f57e6d8f-d43f-e9f8-b092-e43f5019f86f@xenosoft.de>
Date: Tue, 12 Feb 2019 20:50:20 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <47bff9d1-7001-4d92-4ad1-e24215b56555@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12 February 2019 at 8:31PM, Christian Zigotzky wrote:
> On 12 February 2019 at 4:25PM, Christoph Hellwig wrote:
>> On Tue, Feb 12, 2019 at 01:42:56PM +0100, Christian Zigotzky wrote:
>>> On 11 February 2019 at 08:38AM, Christoph Hellwig wrote:
>>>> On Sun, Feb 10, 2019 at 01:00:20PM +0100, Christian Zigotzky wrote:
>>>>> I tested the whole series today. The kernels boot and the P.A. Semi
>>>>> Ethernet works! :-) Thanks a lot!
>>>>>
>>>>> I also tested it in a virtual e5500 QEMU machine today. 
>>>>> Unfortunately the
>>>>> kernel crashes.
>>>> This looks like a patch I fixed in mainline a while ago, but which
>>>> the powerpc tree didn't have yet.
>>>>
>>>> I've cherry picked this commit
>>>> ("swiotlb: clear io_tlb_start and io_tlb_end in swiotlb_exit")
>>>>
>>>> and added it to the powerpc-dma.6 tree, please retry with that one.
>>>>
>>> Hello Christoph,
>>>
>>> Have you added it to the powerpc-dma.6 tree yet? The last commit was 
>>> 4 days
>>> ago.
>> I added it, but forgot to push it out.  It is there now, sorry:
>>
>> http://git.infradead.org/users/hch/misc.git/commitdiff/2cf0745b7420af4a3e871d5a970a45662dfae69c 
>>
>>
> Hi Christoph
>
> Many thanks! Your Git kernel works in a virtual e5500 machine now! :-)
>
> I think we have reached the end of testing! All things are working 
> with your DMA updates.
>
> I am looking forward to testing your DMA changes in the next merge 
> window again. :-)
>
> Cheers
> Christian
>
>
Edit: typo

