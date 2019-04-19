Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2705CC282DF
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 20:08:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFDD12171F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 20:08:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=gmx.net header.i=@gmx.net header.b="GdJtsS0U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFDD12171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gmx.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D2906B0007; Fri, 19 Apr 2019 16:08:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 481596B0008; Fri, 19 Apr 2019 16:08:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34B236B000A; Fri, 19 Apr 2019 16:08:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id F18FC6B0007
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 16:08:43 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g6so1433836wru.3
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 13:08:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=j47E3hXaIZPbHWF7Ycod/UKufYMTUHt3tLu5RUym6bQ=;
        b=LZT6cQcro1dL3D559gUOjWk9Rq/uKs86vNMSm2UTzmjbuDiY0AQEesK7dQteb4A2Cr
         QtY2bjr4Izi+UGhaa60yM1BJzucv5ymDlqXfqHEJOHVWPfZhwriuL9mXVbO5yx9l8PXc
         9SOA4JUWTP5QGYbWAbuxb7dMqANLRg4t2VYFo1I+XMTOFsfu/cIdazdBhNygxJna9Uh0
         +ENKXnmLECvSKzSW6lKZAWuS5WYPaLrK2/tuQmKDCLu9auYrROKDNhcI1ljYwuIO7YMa
         O0hG0nslt63/OuVzVzbxO5xuZ739XuVtBvFthvNAa6gPqiIxDL0HTY/PE02MUeW+Rto7
         ir3Q==
X-Gm-Message-State: APjAAAVSqE5rbiyklbDJl7VxwAA2MuNh8hSu09D2+Npym70rQL3H/zxh
	Prvdbzce6R5DK5n/kbzGIGiIANq7Bt51GyOKSm7QGKoVI+9+T81eNZYNx6v3QOX6HTaY1uHsQ01
	z4YUQYF3fcdh7+mJhiaI31qyPZF0KDQhPmG6MU0w4MSnm8nT+vxnyRWsC6R8h+oOD7Q==
X-Received: by 2002:a1c:4056:: with SMTP id n83mr3702714wma.146.1555704523525;
        Fri, 19 Apr 2019 13:08:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2W7Mymw84C7/0vfmgzVQT+Fa5WgbsNK/iL6xZFBvhJb5/e0oX+6vBLLMjbCgXBDJhvh7R
X-Received: by 2002:a1c:4056:: with SMTP id n83mr3702687wma.146.1555704522661;
        Fri, 19 Apr 2019 13:08:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555704522; cv=none;
        d=google.com; s=arc-20160816;
        b=GqrOfPHXxfo3Qi+TSPaLeplTDmQ8QhkC84eaWP4vu1q77I+qxBZyehh6VCUTkGGffp
         xtD4EreYz8n2VkXSpgCklQAQ6fs5BJTC8hdAXqtP9eBI46FfazCGSR8dTyZ4GFvvKVYR
         LuppvDTLkQGL8+fUcu9e+AfuP7PjU8v35wnCGZUsodgHsqlU8S15HCSl8zjk7DNb6Hz7
         HfaesbMuNxpiV9t8bpqHAex9AzELQRKsHlCBiGH0zjaW2XC+QFMXb/0koZWujG/JmZ8l
         87Q3dGrwVAz+MgsNTl4wzMk6CaHy3gVN5WcyhHJmVMQwnReXgtYb8VlN9ht9epNonD+9
         spug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=j47E3hXaIZPbHWF7Ycod/UKufYMTUHt3tLu5RUym6bQ=;
        b=Htzi1BQMvEvXJJdk3zzLad/EkQbdK92kYNB59uI5kNKeWYLaOeHbd31ZBL3DReYVsX
         5y0RFPIT7sUuXHuitPERrtVXWyHcWLjtC+eHfXyROmcqYXdp51mQ9DmXQs6MTGa4Vo93
         9L98VIbTUZQ/t3ozlF7VNP0xlhiFQfrTxFWRuoYRwFKeSxlXOkMY4y9aqFoakmH/+Fa3
         R6Q1ZCJvyBNf+Xe5iw7HAsdIYnFRP6ZtHC+LBj3i+iKwK1N8Qi624762pWAZW/fYASBl
         /+9ii8TZNhINbvXzwGnmXiMaazH88A5n+yaed5cO2Iupt/GQBLADhdjp/mA910QKbjfi
         T2dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmx.net header.s=badeba3b8450 header.b=GdJtsS0U;
       spf=pass (google.com: domain of deller@gmx.de designates 212.227.17.22 as permitted sender) smtp.mailfrom=deller@gmx.de
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id j5si3901882wrx.365.2019.04.19.13.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 13:08:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of deller@gmx.de designates 212.227.17.22 as permitted sender) client-ip=212.227.17.22;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmx.net header.s=badeba3b8450 header.b=GdJtsS0U;
       spf=pass (google.com: domain of deller@gmx.de designates 212.227.17.22 as permitted sender) smtp.mailfrom=deller@gmx.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=gmx.net;
	s=badeba3b8450; t=1555704514;
	bh=88SiZFmmhRwC/7md4AJCYpTZ6Fy7rhwLCXuvvhMnM9Y=;
	h=X-UI-Sender-Class:Subject:To:Cc:References:From:Date:In-Reply-To;
	b=GdJtsS0UYIdRetD0I+Ks7DHl8xnBOlwqtuowppXDb6B2ENY0zLllx0v8+tTLq+p62
	 791u5+655xbJiXK6ZbIz5QIXDeU0VCT8AW27OOoRWkEbiYXipbWGgzHAiaMAcT3PF2
	 wWPl2OlHZRo6VrWiBvD4jIJrO4Iw2WpwkREzaO9I=
X-UI-Sender-Class: 01bb95c1-4bf8-414a-932a-4f6e2808ef9c
Received: from [192.168.20.60] ([92.116.171.44]) by mail.gmx.com (mrgmx103
 [212.227.17.168]) with ESMTPSA (Nemesis) id 0MegeC-1hSeYE2YSO-00ODox; Fri, 19
 Apr 2019 22:08:34 +0200
Subject: Re: DISCONTIGMEM is deprecated
To: Mel Gorman <mgorman@techsingularity.net>,
 Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Mikulas Patocka <mpatocka@redhat.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 linux-parisc@vger.kernel.org, linux-mm@kvack.org,
 Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
 linux-arch@vger.kernel.org
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <20190419142835.GM18914@techsingularity.net>
From: Helge Deller <deller@gmx.de>
Openpgp: preference=signencrypt
Autocrypt: addr=deller@gmx.de; keydata=
 xsBNBFDPIPYBCAC6PdtagIE06GASPWQJtfXiIzvpBaaNbAGgmd3Iv7x+3g039EV7/zJ1do/a
 y9jNEDn29j0/jyd0A9zMzWEmNO4JRwkMd5Z0h6APvlm2D8XhI94r/8stwroXOQ8yBpBcP0yX
 +sqRm2UXgoYWL0KEGbL4XwzpDCCapt+kmarND12oFj30M1xhTjuFe0hkhyNHkLe8g6MC0xNg
 KW3x7B74Rk829TTAtj03KP7oA+dqsp5hPlt/hZO0Lr0kSAxf3kxtaNA7+Z0LLiBqZ1nUerBh
 OdiCasCF82vQ4/y8rUaKotXqdhGwD76YZry9AQ9p6ccqKaYEzWis078Wsj7p0UtHoYDbABEB
 AAHNHEhlbGdlIERlbGxlciA8ZGVsbGVyQGdteC5kZT7CwJIEEwECADwCGwMGCwkIBwMCBhUI
 AgkKCwQWAgMBAh4BAheAFiEE9M/0wAvkPPtRU6Boh8nBUbUeOGQFAlrHzIICGQEACgkQh8nB
 UbUeOGT1GAgAt+EeoHB4DbAx+pZoGbBYp6ZY8L6211n8fSi7wiwgM5VppucJ+C+wILoPkqiU
 +ZHKlcWRbttER2oBUvKOt0+yDfAGcoZwHS0P+iO3HtxR81h3bosOCwek+TofDXl+TH/WSQJa
 iaitof6iiPZLygzUmmW+aLSSeIAHBunpBetRpFiep1e5zujCglKagsW78Pq0DnzbWugGe26A
 288JcK2W939bT1lZc22D9NhXXRHfX2QdDdrCQY7UsI6g/dAm1d2ldeFlGleqPMdaaQMcv5+E
 vDOur20qjTlenjnR/TFm9tA1zV+K7ePh+JfwKc6BSbELK4EHv8J8WQJjfTphakYLVM7ATQRQ
 zyD2AQgA2SJJapaLvCKdz83MHiTMbyk8yj2AHsuuXdmB30LzEQXjT3JEqj1mpvcEjXrX1B3h
 +0nLUHPI2Q4XWRazrzsseNMGYqfVIhLsK6zT3URPkEAp7R1JxoSiLoh4qOBdJH6AJHex4CWu
 UaSXX5HLqxKl1sq1tO8rq2+hFxY63zbWINvgT0FUEME27Uik9A5t8l9/dmF0CdxKdmrOvGMw
 T770cTt76xUryzM3fAyjtOEVEglkFtVQNM/BN/dnq4jDE5fikLLs8eaJwsWG9k9wQUMtmLpL
 gRXeFPRRK+IT48xuG8rK0g2NOD8aW5ThTkF4apznZe74M7OWr/VbuZbYW443QQARAQABwsBf
 BBgBAgAJBQJQzyD2AhsMAAoJEIfJwVG1HjhkNTgH/idWz2WjLE8DvTi7LvfybzvnXyx6rWUs
 91tXUdCzLuOtjqWVsqBtSaZynfhAjlbqRlrFZQ8i8jRyJY1IwqgvHP6PO9s+rIxKlfFQtqhl
 kR1KUdhNGtiI90sTpi4aeXVsOyG3572KV3dKeFe47ALU6xE5ZL5U2LGhgQkbjr44I3EhPWc/
 lJ/MgLOPkfIUgjRXt0ZcZEN6pAMPU95+u1N52hmqAOQZvyoyUOJFH1siBMAFRbhgWyv+YE2Y
 ZkAyVDL2WxAedQgD/YCCJ+16yXlGYGNAKlvp07SimS6vBEIXk/3h5Vq4Hwgg0Z8+FRGtYZyD
 KrhlU0uMP9QTB5WAUvxvGy8=
Message-ID: <9e7b80a9-b90e-ac04-8b30-b2f285cd4432@gmx.de>
Date: Fri, 19 Apr 2019 22:08:31 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190419142835.GM18914@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:jKfNtqE87ol8fRdlT+ZrUKs8u0n6+ekTNyxZxTDCtgZi2UD62Tv
 Rge/xKNfkt/iueczYZ7jrnjYQUepkQb2HETqx08NAQ2QPH86oI3sEyK+N0Gt8RuE+Rez3r/
 zEe/t3RoTsBjJ2jpG6uKco3FJo1xq39dq2SSz8qeDryfvNa8IZFDty6EYWwuV44zcfPS/w5
 NTK2sl4yXNzb/2Ekt5oqg==
X-UI-Out-Filterresults: notjunk:1;V03:K0:LRTwxRmzW7s=:5glimZF4c8lHgNpScIYCI9
 Gbes011K3KCpwakv6dhniWP2sx3+xvziqzK6FoR+JZ6BRGkXR4cJ4CSJN9skvADwKTgO5Sgf0
 H1wkQ9ER998YXXi7szaPKd+AmTVVcbR5Y0TqptLkpjqaVepXQorlKucp49ecxpq9bZkdL69iU
 ScJzkXdqK0LhXveRfcru1BQroznrDxFBzW2441omFSjo1FJ2GnDl158277HmUs4h5QzvOrHKT
 F9GRvtxLY7em+iTFt5XsQqGkvRx2eGwXEYMc3zirDNg/UGqeMG4IAc2Hd0ZasVorrjf/iVFMh
 5LpkkiF1OIZhCjNetlX/JENDZ4TQZ0YF0eb7779qPm5vWszVCgKTIuZnLmra5gQAO5s2+Gjto
 suK9y9sfJ9kvFhAAkf48Hn4xh/KIvRJDLQQSvGaOfy6ZX30ztVCCv37Vc2LcYnlxQYdkBL0xT
 ioOGmDUI6ESuuDDdG8/w7uTpU0Meof2QhCk26vpoLtDM1hTX0t9wgvJ9vGSrHJZ3qNkpwgZbW
 NU+Jh6uSzsM3SHoOlbWrY/mkk9s3on5zJ1TkModulCkDoBTh1HfEcUnehMbr7EBsNzkTL8l1J
 zWi5cUQJ06v/KD2nw9WdGC3DXBk5wRHg8wgiDkMsDBOczHyPvfbZdFRLxIWEcbl5rMTXnlNiP
 Vv5TKYgitStB2ssc3NRatRDwM8n2ysCTrECIK5ekyCDI7fVPwEm2KLPnqelMWhlEQjmsvw0go
 agQg1/X2m+f2cSrSqQsykoivlHYQAcxMiSbsgVVMVSBTvrZJpcDYuZOLmDQiRDfVP7Z797BUQ
 ifdaD4mSj6VCW0kg1ZE5rfr7AHPc68BmuCo0TUCVvo76lLE/qKkRgaM7TSNXNAeAvpz88NIq9
 MdKedSTytSFnPO1vCIi9k0zeOTlkdeTjXuFYt+OywWi4mTn2IH4WLxrrrXAwdQ
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19.04.19 16:28, Mel Gorman wrote:
> On Fri, Apr 19, 2019 at 07:05:21AM -0700, Matthew Wilcox wrote:
>> On Fri, Apr 19, 2019 at 10:43:35AM +0100, Mel Gorman wrote:
>>> DISCONTIG is essentially deprecated and even parisc plans to move to
>>> SPARSEMEM so there is no need to be fancy, this patch simply disables
>>> watermark boosting by default on DISCONTIGMEM.
>>
>> I don't think parisc is the only arch which uses DISCONTIGMEM for !NUMA
>> scenarios.  Grepping the arch/ directories shows:
>>
>> alpha (does support NUMA, but also non-NUMA DISCONTIGMEM)
>> arc (for supporting more than 1GB of memory)
>> ia64 (looks complicated ...)
>> m68k (for multiple chunks of memory)
>> mips (does support NUMA but also non-NUMA)
>> parisc (both NUMA and non-NUMA)
>>
>> I'm not sure that these architecture maintainers even know that DISCONT=
IGMEM
>> is deprecated.  Adding linux-arch to the cc.
>
> Poor wording then -- yes, DISCONTIGMEM is still used but look where it's
> used. I find it impossible to believe that any new arch would support
> DISCONTIGMEM or that DISCONTIGMEM would be selected when SPARSEMEM is
> available.`It's even more insane when you consider that SPARSEMEM can be
> extended to support VMEMMAP so that it has similar overhead to FLATMEM
> when mapping pfns to struct pages and vice-versa.

FYI, on parisc we will switch from DISCONTIGMEM to SPARSEMEM with kernel 5=
.2.
The patch was quite simple and it's currently in the for-next tree:
https://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux.git/co=
mmit/?h=3Dfor-next&id=3D281b718721a5e78288271d632731cea9697749f7

Helge

