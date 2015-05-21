Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 089E782966
	for <linux-mm@kvack.org>; Thu, 21 May 2015 19:10:42 -0400 (EDT)
Received: by ieczm2 with SMTP id zm2so19758163iec.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 16:10:41 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id s66si247968ioi.60.2015.05.21.16.10.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 May 2015 16:10:41 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v6 5/5] trace, ras: move ras_event.h under
 include/trace/events
Date: Thu, 21 May 2015 23:00:24 +0000
Message-ID: <20150521230024.GA4052@hori1.linux.bs1.fc.nec.co.jp>
References: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
 <1432179685-11369-6-git-send-email-xiexiuqi@huawei.com>
 <20150521092437.GA3841@nazgul.tnic>
 <20150521090152.182a46ef@gandalf.local.home>
In-Reply-To: <20150521090152.182a46ef@gandalf.local.home>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E83D26A8CB802349A5B043AF7DFC3DA0@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Borislav Petkov <bp@suse.de>, Xie XiuQi <xiexiuqi@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "mingo@redhat.com" <mingo@redhat.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "rdunlap@infradead.org" <rdunlap@infradead.org>, "jim.epost@gmail.com" <jim.epost@gmail.com>

On Thu, May 21, 2015 at 09:01:52AM -0400, Steven Rostedt wrote:
> On Thu, 21 May 2015 11:24:37 +0200
> Borislav Petkov <bp@suse.de> wrote:
>=20
> > On Thu, May 21, 2015 at 11:41:25AM +0800, Xie XiuQi wrote:
> > > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > >=20
> > > Most of header files for tracepoints are located to include/trace/eve=
nts or
> > > their relevant subdirectories under drivers/. One exception is
> >=20
> > That's simply not true.
> >=20
> > > include/ras/ras_events.h, which looks inconsistent. So let's move it =
to the
> > > default places for such headers.
> >=20
> > No thanks - ras TPs can live just fine in include/ras/.
> >=20
>=20
> I agree with Boris, the solution is not to move it. It's not
> inconsistent, lots of places use it. Just do a git grep -l TRACE_EVENT
> to see.

My bad, I withdraw this patch.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
