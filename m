Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E2F5D6B0259
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 05:56:13 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so172328132pad.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:56:13 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id uv9si30536980pac.183.2015.09.15.02.56.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 02:56:13 -0700 (PDT)
From: Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: [PATCH 0/1] Fix false-negative error reporting from fsync/fdatasync
Date: Tue, 15 Sep 2015 09:46:39 +0000
Message-ID: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9F23CF1F60D32E46A675B86DCFBCBB8E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "liwanp@linux.vnet.ibm.com" <liwanp@linux.vnet.ibm.com>, "david@fromorbit.com" <david@fromorbit.com>, Tejun Heo <tj@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Applications use fsync/fdatasync to make sure data is written back to
storage. It is expected that those system calls return error if
writeback has failed (e.g. disk/transport failure, memory failure..)

However if admins run a command such as sync or fsfreeze along side,
fsync/fdatasync may return success even if writeback has failed.
That could lead to data corruption.

This patch is a minimal fix for the problem.
--=20
Jun'ichi Nomura, NEC Corporation=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
