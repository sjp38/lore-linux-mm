Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFE496B0009
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 17:18:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e9so10051114pfn.16
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:18:52 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0094.outbound.protection.outlook.com. [104.47.36.94])
        by mx.google.com with ESMTPS id 67si11438871pfr.239.2018.04.16.14.18.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 14:18:51 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 21:18:47 +0000
Message-ID: <20180416211845.GP2341@sasha-vm>
References: <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm>
 <20180416170501.GB11034@amd> <20180416171607.GJ2341@sasha-vm>
 <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm>
 <20180416203629.GO2341@sasha-vm>
 <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <71695765C21E1243B01B601B0493E383@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 10:43:28PM +0200, Jiri Kosina wrote:
>On Mon, 16 Apr 2018, Sasha Levin wrote:
>
>> So I think that Linus's claim that users come first applies here as
>> well. If there's a user that cares about a particular feature being
>> broken, then we go ahead and fix his bug rather then ignoring him.
>
>So one extreme is fixing -stable *iff* users actually do report an issue.
>
>The other extreme is backporting everything that potentially looks like a
>potential fix of "something" (according to some arbitrary metric),
>pro-actively.
>
>The former voilates the "users first" rule, the latter has a very, very
>high risk of regressions.
>
>So this whole debate is about finding a compromise.
>
>My gut feeling always was that the statement in
>
>	Documentation/process/stable-kernel-rules.rst
>
>is very reasonable, but making the process way more "aggresive" when
>backporting patches is breaking much of its original spirit for me.

I agree that as an enterprise distro taking everything from -stable
isn't the best idea. Ideally you'd want to be close to the first
extreme you've mentioned and only take commits if customers are asking
you to do so.

I think that the rule we're trying to agree upon is the "It must fix
a real bug that bothers people".

I think that we can agree that it's impossible to expect every single
Linux user to go on LKML and complain about a bug he encountered, so the
rule quickly becomes "It must fix a real bug that can bother people".

My "aggressiveness" comes from the whole "bother" part: it doesn't have
to be critical, it doesn't have to cause data corruption, it doesn't
have to be a security issue. It's enough that the bug actually affects a
user in a way he didn't expect it to (if a user doesn't have
expectations, it would fall under the "This could be a problem..."
exception.

We can go into a discussion about what exactly "bothering" is, but on
the flip side, the whole -stable tag is just a way for folks to indicate
they want a given patch reviewed for stable, it's not actually a
guarantee of whether the patch will go in to -stable or not.=
