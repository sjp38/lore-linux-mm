Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A7FD16B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 04:18:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BC6F13EE0CD
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:18:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A2C8045DF5C
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:18:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 88C9145DF57
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:18:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 78D5B1DB802C
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:18:53 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 31FAB1DB803E
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:18:53 +0900 (JST)
Message-ID: <4DDE0CDD.5050000@jp.fujitsu.com>
Date: Thu, 26 May 2011 17:18:37 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Easy portable testcase! (Re: Kernel falls apart under light memory
 pressure (i.e. linking vmlinux))
References: <BANLkTinptn4-+u+jgOr2vf2iuiVS3mmYXA@mail.gmail.com>
In-Reply-To: <BANLkTinptn4-+u+jgOr2vf2iuiVS3mmYXA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: luto@mit.edu
Cc: minchan.kim@gmail.com, aarcange@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

(2011/05/26 5:17), Andrew Lutomirski wrote:
> On Tue, May 24, 2011 at 8:43 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>> Unfortnately, this log don't tell us why DM don't issue any swap io. ;-)
>> I doubt it's DM issue. Can you please try to make swap on out of DM?
>>
>>
> 
> I can do one better: I can tell you how to reproduce the OOM in the
> comfort of your own VM without using dm_crypt or a Sandy Bridge
> laptop.  This is on Fedora 15, but it really ought to work on any
> x86_64 distribution that has kvm.  You'll probably want at least 6GB
> on your host machine because the VM wants 4GB ram.

Hmmm....

I don't have 6GB memory. :-)
I'll try to borrow it from anywhere, but I'd expect my response is delayed
some time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
