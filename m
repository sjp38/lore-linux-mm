Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 249266B007E
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 03:08:14 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so52711378pac.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 00:08:14 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id h124si12678506pfb.179.2016.04.20.00.08.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Apr 2016 00:08:10 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: mce: a question about memory_failure_early_kill in
 memory_failure()
Date: Wed, 20 Apr 2016 07:07:35 +0000
Message-ID: <20160420070735.GA10125@hori1.linux.bs1.fc.nec.co.jp>
References: <571612DE.8020908@huawei.com>
In-Reply-To: <571612DE.8020908@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6DA2EE554D16DD44933968A549DFD0EF@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 19, 2016 at 07:13:34PM +0800, Xishi Qiu wrote:
> /proc/sys/vm/memory_failure_early_kill
>=20
> 1: means kill all processes that have the corrupted and not reloadable pa=
ge mapped.
> 0: means only unmap the corrupted page from all processes and only kill a=
 process
> who tries to access it.
>=20
> If set memory_failure_early_kill to 0, and memory_failure() has been call=
ed.
> memory_failure()
> 	hwpoison_user_mappings()
> 		collect_procs()  // the task(with no PF_MCE_PROCESS flag) is not in the=
 tokill list
> 			try_to_unmap()
>=20
> If the task access the memory, there will be a page fault,
> so the task can not access the original page again, right?

Yes, right. That's the behavior in default "late kill" case.

I'm guessing that you might have a more specific problem around this code.
If so, please feel free to ask with detail.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
