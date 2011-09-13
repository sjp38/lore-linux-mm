Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 143CF900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 02:56:45 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p8D6uhjp018998
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 23:56:43 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by wpaz13.hot.corp.google.com with ESMTP id p8D6ucWK016246
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 23:56:42 -0700
Received: by pzk4 with SMTP id 4so574509pzk.28
        for <linux-mm@kvack.org>; Mon, 12 Sep 2011 23:56:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E6E39DD.2040102@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
 <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
 <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
 <4E66A0A9.3060403@parallels.com> <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com>
 <4E68484A.4000201@parallels.com> <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com>
 <4E699341.9010606@parallels.com> <CALdu-PCrYPZx38o44ZyFrbQ6H39-vNPKey_Tpm4HRUNHNFMpyA@mail.gmail.com>
 <4E6E39DD.2040102@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 12 Sep 2011 23:56:18 -0700
Message-ID: <CAHH2K0aOHPW2xqb86sN4A3xBwZKU0qgnZ05cn-3XKES392tftg@mail.gmail.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>, Lennart Poettering <lennart@poettering.net>

On Mon, Sep 12, 2011 at 9:57 AM, Glauber Costa <glommer@parallels.com> wrote:
> On 09/12/2011 02:03 AM, Paul Menage wrote:
>> I definitely think that there was no consensus reached on unified
>> versus split charging - but I think that we can work around that and
>> keep everyone happy, see below.
>
> I think at this point there is at least consensus that this could very well
> live in memcg, right ?

Yes, I think it should live in memcg.

>> On the subject of filesystems specifically, see Greg Thelen's proposal
>> for using bind mounts to account on a bind mount to a given cgroup -
>> that could apply to dentries, page tables and other kernel memory as
>> well as page cache.
>
> Care to point me to it ?

http://marc.info/?t=127749867100004&r=1&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
