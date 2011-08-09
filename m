Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 30C44900137
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 05:54:35 -0400 (EDT)
Received: by wwj26 with SMTP id 26so3109058wwj.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 02:54:32 -0700 (PDT)
Subject: Re: [PATCH] slub: fix check_bytes() for slub debugging
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <CAOJsxLHKJT_qCsiPVCEh=+nbZ2D7+y=mJgMM+wEob395zEN6XQ@mail.gmail.com>
References: <1312709438-7608-1-git-send-email-akinobu.mita@gmail.com>
	 <1312859440.2531.20.camel@edumazet-laptop>
	 <1312860783.2531.31.camel@edumazet-laptop>
	 <CAC5umyhLuhNK55WDXTii2SFsqPNau1B9F1z+E0r0CaLNkGZfDg@mail.gmail.com>
	 <CAOJsxLHKJT_qCsiPVCEh=+nbZ2D7+y=mJgMM+wEob395zEN6XQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Aug 2011 11:54:31 +0200
Message-ID: <1312883671.2371.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

Le mardi 09 aoA>>t 2011 A  12:43 +0300, Pekka Enberg a A(C)crit :

> I'm confused. What was wrong with your original patch?
> 

Patch is good. Some future improvements will follow.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
