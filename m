Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 39F146B0266
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 16:40:27 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id y23-v6so1920838qtc.7
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 13:40:27 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0132.outbound.protection.outlook.com. [104.47.38.132])
        by mx.google.com with ESMTPS id 24-v6si2547677qvd.223.2018.10.01.13.40.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Oct 2018 13:40:26 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Date: Mon, 1 Oct 2018 20:40:24 +0000
Message-ID: <20181001204022.GE69414@sasha-vm>
References: <20180927194601.207765-1-wonderfly@google.com>
 <20181001152324.72a20bea@gandalf.local.home>
 <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
In-Reply-To: 
 <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <748043772AB90F488DD1B400A54E69CC@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: "rostedt@goodmis.org" <rostedt@goodmis.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "pmladek@suse.com" <pmladek@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "jack@suse.cz" <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mathieu.desnoyers@efficios.com" <mathieu.desnoyers@efficios.com>, "mgorman@suse.de" <mgorman@suse.de>, "mhocko@kernel.org" <mhocko@kernel.org>, "pavel@ucw.cz" <pavel@ucw.cz>, "penguin-kernel@i-love.sakura.ne.jp" <penguin-kernel@i-love.sakura.ne.jp>, "peterz@infradead.org" <peterz@infradead.org>, "tj@kernel.org" <tj@kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Mon, Oct 01, 2018 at 01:37:30PM -0700, Daniel Wang wrote:
>On Mon, Oct 1, 2018 at 12:23 PM Steven Rostedt <rostedt@goodmis.org> wrote=
:
>>
>> > Serial console logs leading up to the deadlock. As can be seen the sta=
ck trace
>> > was incomplete because the printing path hit a timeout.
>>
>> I'm fine with having this backported.
>
>Thanks. I can send the cherrypicks your way. Do you recommend that I
>include the three follow-up fixes though?
>
>c14376de3a1b printk: Wake klogd when passing console_lock owner
>fd5f7cde1b85 printk: Never set console_may_schedule in console_trylock()
>c162d5b4338d printk: Hide console waiter logic into helpers
>dbdda842fe96 printk: Add console owner and waiter logic to load
>balance console writes

Maybe it'll also make sense to make the reproducer into a test that can
go under tools/testing/ and we can backport that as well? It'll be
helpful to have a way to make sure things are sane.

--
Thanks,
Sasha=
