Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 04D436B008C
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 21:10:16 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id oB82ACea021082
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 18:10:12 -0800
Received: from yxt33 (yxt33.prod.google.com [10.190.5.225])
	by hpaq11.eem.corp.google.com with ESMTP id oB829u9Y013839
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 18:10:11 -0800
Received: by yxt33 with SMTP id 33so429104yxt.17
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 18:10:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101208102812.5b93c1bc.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101207123308.GD5422@csn.ul.ie>
	<AANLkTimzL_CwLruzPspgmOk4OJU8M7dXycUyHmhW2s9O@mail.gmail.com>
	<20101208093948.1b3b64c5.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTin+p5WnLjMkr8Qntkt4fR1+fdY=t6hkvV6G8Mok@mail.gmail.com>
	<20101208102812.5b93c1bc.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 7 Dec 2010 18:10:11 -0800
Message-ID: <AANLkTikXO1YxzX2PJyKobeb=Cg_EhTVW9-pBFnPE9dYh@mail.gmail.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 7, 2010 at 5:28 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 7 Dec 2010 17:24:12 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> On Tue, Dec 7, 2010 at 4:39 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Tue, 7 Dec 2010 09:28:01 -0800
>> > Ying Han <yinghan@google.com> wrote:
>> >
>> >> On Tue, Dec 7, 2010 at 4:33 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> >
>> >> Potentially there will
>> >> > also be a very large number of new IO sources. I confess I haven't =
read the
>> >> > thread yet so maybe this has already been thought of but it might m=
ake sense
>> >> > to have a 1:N relationship between kswapd and memcgroups and cycle =
between
>> >> > containers. The difficulty will be a latency between when kswapd wa=
kes up
>> >> > and when a particular container is scanned. The closer the ratio is=
 to 1:1,
>> >> > the less the latency will be but the higher the contenion on the LR=
U lock
>> >> > and IO will be.
>> >>
>> >> No, we weren't talked about the mapping anywhere in the thread. Havin=
g
>> >> many kswapd threads
>> >> at the same time isn't a problem as long as no locking contention (
>> >> ext, 1k kswapd threads on
>> >> 1k fake numa node system). So breaking the zone->lru_lock should work=
