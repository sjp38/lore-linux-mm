Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id A35B36B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 21:00:22 -0400 (EDT)
Received: by oiev17 with SMTP id v17so106190493oie.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 18:00:22 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id du6si11450979oeb.29.2015.09.15.18.00.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 18:00:21 -0700 (PDT)
From: Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: Re: [PATCH 1/1] fs: global sync to not clear error status of
 individual inodes
Date: Wed, 16 Sep 2015 00:45:42 +0000
Message-ID: <20150916004541.GA6059@xzibit.linux.bs1.fc.nec.co.jp>
References: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915095412.GD13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915143723.GA1747@two.firstfloor.org>
 <20150915150254.6c78985cb271c7104b3ee717@linux-foundation.org>
In-Reply-To: <20150915150254.6c78985cb271c7104b3ee717@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D3F465B654181841AD0A8C3CF5F1B381@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, Tejun Heo <tj@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 09/16/15 07:02, Andrew Morton wrote:
> It would be nice to capture the test case(s) somewhere permanent.=20
> Possibly in tools/testing/selftests, but selftests is more for peculiar
> linux-specific things.  LTP or xfstests would be a better place.

I'll check xfstests if I can adapt the test case for its framework.

--=20
Jun'ichi Nomura, NEC Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
