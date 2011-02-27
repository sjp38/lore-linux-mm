Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2A1A8D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 05:07:42 -0500 (EST)
Received: by yxt33 with SMTP id 33so1596003yxt.14
        for <linux-mm@kvack.org>; Sun, 27 Feb 2011 02:07:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1102262132320.12215@chino.kir.corp.google.com>
References: <20110225105205.5a1309bb.randy.dunlap@oracle.com>
	<1298747426-8236-1-git-send-email-mk@lab.zgora.pl>
	<alpine.DEB.2.00.1102262132320.12215@chino.kir.corp.google.com>
Date: Sun, 27 Feb 2011 12:07:41 +0200
Message-ID: <AANLkTimAC8VmpQ1ZAAAy1Wu5ZHffcDqp96MyzRoywjTc@mail.gmail.com>
Subject: Re: [PATCH] slub: fix ksize() build error
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mariusz Kozlowski <mk@lab.zgora.pl>, Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Eric Dumazet <eric.dumazet@gmail.com>, linux-next@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>

Hi,

[ Please CC me for slab allocator patches in the future. ]

On Sun, Feb 27, 2011 at 7:32 AM, David Rientjes <rientjes@google.com> wrote:
> On Sat, 26 Feb 2011, Mariusz Kozlowski wrote:
>
>> mm/slub.c: In function 'ksize':
>> mm/slub.c:2728: error: implicit declaration of function 'slab_ksize'
>>
>> slab_ksize() needs to go out of CONFIG_SLUB_DEBUG section.
>>
>> Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>
>
> Acked-by: David Rientjes <rientjes@google.com>

Applied, thanks!

                      Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
