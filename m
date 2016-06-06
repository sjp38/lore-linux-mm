Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF5736B0262
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 16:12:38 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t65so117834602qkh.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 13:12:38 -0700 (PDT)
Received: from mail-yw0-x233.google.com (mail-yw0-x233.google.com. [2607:f8b0:4002:c05::233])
        by mx.google.com with ESMTPS id j144si4993605ybg.174.2016.06.06.13.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 13:12:38 -0700 (PDT)
Received: by mail-yw0-x233.google.com with SMTP id o16so150922052ywd.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 13:12:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160606201156.GB32247@mwanda>
References: <20160606195228.GA27327@mwanda> <CAJcbSZEcW8u2Mx0awZO_8g38pnSAYfPR8e37oBEDPvFZQWv_fQ@mail.gmail.com>
 <20160606201156.GB32247@mwanda>
From: Thomas Garnier <thgarnie@google.com>
Date: Mon, 6 Jun 2016 13:12:37 -0700
Message-ID: <CAJcbSZH19--sNScrmwpHwUprUzaSXY5FCkWPmm_a-mF620nExA@mail.gmail.com>
Subject: Re: mm: reorganize SLAB freelist randomization
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Linux-MM <linux-mm@kvack.org>

Thanks a lot for running static checkers on the code.

On Mon, Jun 6, 2016 at 1:11 PM, Dan Carpenter <dan.carpenter@oracle.com> wr=
ote:
> On Mon, Jun 06, 2016 at 01:01:45PM -0700, Thomas Garnier wrote:
>> No, the for loop is correct. Fisher-Yates shuffles algorithm is as follo=
w:
>>
>> -- To shuffle an array a of n elements (indices 0..n-1):
>> for i from n=E2=88=921 downto 1 do
>>      j random integer such that 0 <=3D j <=3D i
>>      exchange a[j] and a[i]
>>
>> https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
>
> Thanks for looking at this.  :)
>
> regards,
> dan carpenter
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
