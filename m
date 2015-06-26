Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D41196B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 21:42:20 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so42661104pdb.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:42:20 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id z10si47782763pdl.29.2015.06.25.18.42.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 18:42:20 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so42660935pdb.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:42:19 -0700 (PDT)
Date: Fri, 26 Jun 2015 10:42:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: extremely long blockages when doing random writes to SSD
Message-ID: <20150626014248.GA26543@swordfish>
References: <CAA25o9SCnDYZ6vXWQWEWGDiwpV9rf+S_3Np8nJrWqHJ1x6-kMg@mail.gmail.com>
 <20150624152518.d3a5408f2bde405df1e6e5c4@linux-foundation.org>
 <CAA25o9RNLr4Gk_4m56bAf7_RBsObrccFWPtd-9jwuHg1NLdRTA@mail.gmail.com>
 <CAA25o9ShiKyPTBYbVooA=azb+XO9PWFtididoyPa4s-v56mvBg@mail.gmail.com>
 <20150626005808.GA5704@swordfish>
 <CAA25o9TCj0YSw1JhuPVsu9PzEMwnC2pLHNvNdMa+0OpJd1X64Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9TCj0YSw1JhuPVsu9PzEMwnC2pLHNvNdMa+0OpJd1X64Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On (06/25/15 18:31), Luigi Semenzato wrote:
> We're using CFQ.
> 
> CONFIG_DEFAULT_IOSCHED="cfq"
> ...
> CONFIG_IOSCHED_CFQ=y
> CONFIG_IOSCHED_DEADLINE=y
> CONFIG_IOSCHED_NOOP=y
> 

any chance to try out DEADLINE?
CFQ, as far as I understand, doesn't make too much sense for SSDs.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
