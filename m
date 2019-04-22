Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1516EC10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:31:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C543B20896
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:31:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="oLnlTenx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C543B20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 653116B0010; Mon, 22 Apr 2019 15:31:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FFC86B0266; Mon, 22 Apr 2019 15:31:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47C596B0269; Mon, 22 Apr 2019 15:31:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0ADE66B0010
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:31:57 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id x9so8895904pln.0
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:31:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WH/Ljdr8TJUTrAi5oLGMpFDZ+oLv/QGAaimWLH/RF5Y=;
        b=Hwya1FvZXWGmmwhbjzVia0SL/OW1yxhzFyACHMdTR20gG611AgScCrRGk+Ke3aSzcg
         LjuRCuiqueCMX1Hsmb/ZCZSGoSkvbI9jCen7IoiSs5aHrb+l85kbnsej3HWkv0X+h43/
         nxbbwORwpQhq/j6h6gz1f8/obir/rCrURJoD0s82sNRvzvBV2fkqRjJ0536Yg8QgHzjn
         eNQ+zWxfGxR84cwRHxFQ5QBV1i2V/eXW6qGiV8oHGLTgHZdKfwe1D8tAtS3zeuA8wXiV
         WNWRBwEAT6AiQ1imkeCybTaD8bBXxyEmdNryKMyE1gMlkd+0jZeAOaQNHZ8HZxmJBLB2
         b/8A==
X-Gm-Message-State: APjAAAV6XP98pr8qvjogSRivmrymzu6/4dXOS/fiZROcWkdZIznmpRpq
	AOmM+4JQ8X0P980FbJDNTETbv2gdLcwZe5iPcLfcp7o1k7+86y+rBcYwBWAQmwkUmASeCMlLdzL
	z7wR5Aq+PnM3p+rORgzExdWPcSMb/reD1jEE88mDSfMuCxtTW6udlwbG/6ZXoCw5GXg==
X-Received: by 2002:a63:c944:: with SMTP id y4mr20905259pgg.257.1555961516495;
        Mon, 22 Apr 2019 12:31:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdW2eGH032NqNRcUJ6B5v8/9LvA3rGapbQipbHwFj8tHenuoMkuAXI93C06PI+J5a0wYu0
X-Received: by 2002:a63:c944:: with SMTP id y4mr20905190pgg.257.1555961515515;
        Mon, 22 Apr 2019 12:31:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555961515; cv=none;
        d=google.com; s=arc-20160816;
        b=w/RZEo3pvwu67/tElTI7tldH3AtYEfC0KSLizWeyql+Qrmv/HPoWCzhZSpCxM1ndam
         15JSTrthogPI0MMMsoWDlIG+xt+PQuetr/uPey/ZvWBhDQERTAdkRrx2TLKMeA0Mux5A
         6XijknVn+XplJ7KNhHrAlYbJuwPjIPGrqw+M/CSq4+zb/RYapAB/T8ZB3uvFLRJPMxu0
         +qAbVem1iHN52QcNstPufAAOLhIDs7KEfVkTXeGlp8jDSOek+vqfqaDiNSjDPRsYIJ+/
         oDIkD/4Fgpcmp7cCobB426bWfub5JZRPwarWXrtnHhPeDtLZIQi+VX7Dvf9DRRnssViM
         jcZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:references:cc:to:from
         :subject:dkim-signature;
        bh=WH/Ljdr8TJUTrAi5oLGMpFDZ+oLv/QGAaimWLH/RF5Y=;
        b=ekucMn3qtpq+t3K1g1PhfSb6352lDAcfmPGo7KKFEvbm0+qwYibDgpclKyhrYGsj6S
         An6lA8egHN+P+3NNc+iW7oNtKOqvqrNAwWDppATwRDk+fOrYj95TjhtmDe6+UVpq31+4
         CPO3zCQZrHG07TpQdTfNI+JAbz0tWwhmRHprP6ffGWowDXWONQt51OU68nSj6v34G/1t
         U2icTNGQsd2I5pSnW9qmLjttxI6ngxGRp0I78koNAfvw9O3J6FcYgB7AZZdEXnK0hwMX
         PGdfE1MLNf31xeExwaN+FW7GQrq6T/w3Wlyqch7jcuDhtTw+/Rq2itr7qhcBqvlCT8br
         b+Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=oLnlTenx;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o19si13176759pgk.324.2019.04.22.12.31.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 12:31:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=oLnlTenx;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3MJUDBB049863;
	Mon, 22 Apr 2019 19:30:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=WH/Ljdr8TJUTrAi5oLGMpFDZ+oLv/QGAaimWLH/RF5Y=;
 b=oLnlTenxF7nnPodU74CKxVdtTdurZTHC2c+IYDHYu4ConBppy1DQR5ZRD2yjJFvZgGWr
 s4yQwwuUvTu9u+sFyoVUu0Ps8OuhhW0poWi1ZMLvaVC5TBbAF1wwcZr5XAReyOOTF+by
 uC0TnLDiZT5r3TKE6PPp1vUjAz4Kig9RayQOAPeSyneDjrd8g3giZqr3VY0DWHpHGibW
 +Tp8jlms4x1+K3jD0LKvfWig3toDL2oxHG0Gk75UGHP6ZXqvAC5kZivppkWtzcLz1h9X
 XEAwsf7cBrXzU2kQ/Ajn/P/r+v3zskWbTDpMTbY0n+hrjLQtUDBZ3bbfv/WSjVOTlFLG 6g== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2ryv2q001q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Apr 2019 19:30:53 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3MJUfFP107047;
	Mon, 22 Apr 2019 19:30:52 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2s0dwdv8c5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Apr 2019 19:30:52 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3MJUjCf011034;
	Mon, 22 Apr 2019 19:30:46 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 22 Apr 2019 12:30:45 -0700
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
From: Khalid Aziz <khalid.aziz@oracle.com>
To: Kees Cook <keescook@google.com>, Andy Lutomirski <luto@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>,
        Ingo Molnar <mingo@kernel.org>, Juerg Haefliger <juergh@gmail.com>,
        Tycho Andersen <tycho@tycho.ws>, Julian Stecklina <jsteckli@amazon.de>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        David Woodhouse <dwmw@amazon.co.uk>,
        Andrew Cooper <andrew.cooper3@citrix.com>,
        Jon Masters <jcm@redhat.com>,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        iommu <iommu@lists.linux-foundation.org>, X86 ML <x86@kernel.org>,
        "linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>,
        "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
        Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Khalid Aziz <khalid@gonehiking.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave@sr71.net>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Arjan van de Ven <arjan@infradead.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com>
 <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com>
 <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com>
 <20190417172632.GA95485@gmail.com>
 <063753CC-5D83-4789-B594-019048DE22D9@gmail.com>
 <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de>
 <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com>
 <alpine.DEB.2.21.1904180129000.3174@nanos.tec.linutronix.de>
 <CAHk-=whUwOjFW6RjHVM8kNOv1QVLJuHj2Dda0=mpLPdJ1UyatQ@mail.gmail.com>
 <CALCETrXm9PuUTEEmzA8bQJmg=PHC_2XSywECittVhXbMJS1rSA@mail.gmail.com>
 <CAGXu5jL-qJtW7eH8S2yhqciE+J+FWz8HHzTrGJTgVUbd55n6dQ@mail.gmail.com>
 <8f9d059d-e720-cd24-faa6-45493fc012e0@oracle.com>
Organization: Oracle Corp
Message-ID: <302e3d5b-d2fd-3c25-335b-466ba83035c5@oracle.com>
Date: Mon, 22 Apr 2019 13:30:41 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <8f9d059d-e720-cd24-faa6-45493fc012e0@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9235 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904220147
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9235 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904220147
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 8:34 AM, Khalid Aziz wrote:
> On 4/17/19 11:41 PM, Kees Cook wrote:
>> On Wed, Apr 17, 2019 at 11:41 PM Andy Lutomirski <luto@kernel.org> wro=
te:
>>> I don't think this type of NX goof was ever the argument for XPFO.
>>> The main argument I've heard is that a malicious user program writes =
a
>>> ROP payload into user memory (regular anonymous user memory) and then=

>>> gets the kernel to erroneously set RSP (*not* RIP) to point there.
>>
>> Well, more than just ROP. Any of the various attack primitives. The NX=

>> stuff is about moving RIP: SMEP-bypassing. But there is still basic
>> SMAP-bypassing for putting a malicious structure in userspace and
>> having the kernel access it via the linear mapping, etc.
>>
>>> I find this argument fairly weak for a couple reasons.  First, if
>>> we're worried about this, let's do in-kernel CFI, not XPFO, to
>>
>> CFI is getting much closer. Getting the kernel happy under Clang, LTO,=

>> and CFI is under active development. (It's functional for arm64
>> already, and pieces have been getting upstreamed.)
>>
>=20
> CFI theoretically offers protection with fairly low overhead. I have no=
t
> played much with CFI in clang. I agree with Linus that probability of
> bugs in XPFO implementation itself is a cause of concern. If CFI in
> Clang can provide us the same level of protection as XPFO does, I
> wouldn't want to push for an expensive change like XPFO.
>=20
> If Clang/CFI can't get us there for extended period of time, does it
> make sense to continue to poke at XPFO?

Any feedback on continued effort on XPFO? If it makes sense to have XPFO
available as a solution for ret2dir issue in case Clang/CFI does not
work out, I will continue to refine it.

--
Khalid

