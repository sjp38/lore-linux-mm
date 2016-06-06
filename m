Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54F526B0260
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 16:11:45 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id w64so135128778iow.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 13:11:45 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id oq9si28373394pab.228.2016.06.06.13.11.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 13:11:44 -0700 (PDT)
Date: Mon, 6 Jun 2016 23:11:56 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: mm: reorganize SLAB freelist randomization
Message-ID: <20160606201156.GB32247@mwanda>
References: <20160606195228.GA27327@mwanda>
 <CAJcbSZEcW8u2Mx0awZO_8g38pnSAYfPR8e37oBEDPvFZQWv_fQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJcbSZEcW8u2Mx0awZO_8g38pnSAYfPR8e37oBEDPvFZQWv_fQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Linux-MM <linux-mm@kvack.org>

On Mon, Jun 06, 2016 at 01:01:45PM -0700, Thomas Garnier wrote:
> No, the for loop is correct. Fisher-Yates shuffles algorithm is as follow:
> 
> -- To shuffle an array a of n elements (indices 0..n-1):
> for i from na??1 downto 1 do
>      j random integer such that 0 <= j <= i
>      exchange a[j] and a[i]
> 
> https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle

Thanks for looking at this.  :)

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
