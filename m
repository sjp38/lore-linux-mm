Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 350416B004D
	for <linux-mm@kvack.org>; Fri, 22 May 2009 04:35:44 -0400 (EDT)
Message-ID: <4A16644F.1090201@cn.fujitsu.com>
Date: Fri, 22 May 2009 16:37:35 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: remove forward declaration from sched.h
References: <4A1645D4.5010001@cn.fujitsu.com> <20090522171737.e9916d1b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090522171737.e9916d1b.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 22 May 2009 14:27:32 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> This forward declaration seems pointless.
>>
>> compile tested.
>>
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> Nice catch. (but I don't know why this sneaked into..)

It was long long ago when memcg was merged ;)

| commit 78fb74669e80883323391090e4d26d17fe29488f
| Author: Pavel Emelianov <xemul@openvz.org>
| Date:   Thu Feb 7 00:13:51 2008 -0800
|
|    Memory controller: accounting setup

But in that patch, the forward declation in sched.h was unneeded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
