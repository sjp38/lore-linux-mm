Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 228536B0099
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 00:52:27 -0500 (EST)
Message-ID: <4ECDDB86.5000208@redhat.com>
Date: Thu, 24 Nov 2011 13:52:06 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
References: <1322038412-29013-1-git-send-email-amwang@redhat.com>	<20111124105245.b252c65f.kamezawa.hiroyu@jp.fujitsu.com>	<CAHGf_=oD0Coc=k5kAAQoP=GqK+nc0jd3qq3TmLZaitSjH-ZPmQ@mail.gmail.com>	<20111124120126.9361b2c9.kamezawa.hiroyu@jp.fujitsu.com>	<4ECDB87A.90106@redhat.com> <20111124132349.ca862c9e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111124132349.ca862c9e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, linux-mm@kvack.org

于 2011年11月24日 12:23, KAMEZAWA Hiroyuki 写道:
> 
> thank you for checking. So, at failure path, original data should not be
> cleared, either.
> 

Yes, sure, I will fix that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
