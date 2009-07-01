Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 497AD6B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 20:26:22 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id n610R56Z023281
	for <linux-mm@kvack.org>; Wed, 1 Jul 2009 01:27:06 +0100
Received: from an-out-0708.google.com (anab38.prod.google.com [10.100.53.38])
	by wpaz5.hot.corp.google.com with ESMTP id n610R3Ks009682
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 17:27:03 -0700
Received: by an-out-0708.google.com with SMTP id b38so235299ana.9
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 17:27:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090701090959.4cbdb03e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830906300215q56bda5ccnc99862211dc65289@mail.gmail.com>
	 <20090630182304.8049039c.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830906300918i3e3f8611r6d6fb7873c720c70@mail.gmail.com>
	 <20090701084037.2c3f53f7.nishimura@mxp.nes.nec.co.jp>
	 <20090701090959.4cbdb03e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 30 Jun 2009 17:27:02 -0700
Message-ID: <6599ad830906301727wcb6b292uc3c46451f8844392@mail.gmail.com>
Subject: Re: [PATCH 2/2] cgroup: exlclude release rmdir
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 5:09 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 1 Jul 2009 08:40:37 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>
>> On Tue, 30 Jun 2009 09:18:03 -0700, Paul Menage <menage@google.com> wrote:
>> > On Tue, Jun 30, 2009 at 2:23 AM, KAMEZAWA
>> > Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > This patch is _not_ tested by Nishimura.
>> >
>> > True, but it's functionally identical to, and simpler than, the one
>> > that was tested.
>> >
>> I agree.
>> I'll test with both of these patches folded.
>>
> Hm,ok. I'll post merged one today.
> But I don't like cosmeticized bugfix patch ;(
>

It only looks "cosmeticized" because of the evolution of your fix. The
first patch added a new function that exposed internal details of
cgroups, and the second patch removes the addition in favour of a
different new function that doesn't expose internal details as much; a
single patch that just adds the simpler new function is easier to
judge as intuitively correct (separately from Daisuke's testing) than
one that exposes more internal details.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
