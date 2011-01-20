Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6E8B66B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 20:22:16 -0500 (EST)
Date: Thu, 20 Jan 2011 02:21:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: 2.6.38-rc1 problems with khugepaged
Message-ID: <20110120012158.GT9506@random.random>
References: <web-442414153@zbackend1.aha.ru>
 <20110119155954.GA2272@kryptos.osrc.amd.com>
 <20110119214523.GF2232@cmpxchg.org>
 <20110120000147.GR9506@random.random>
 <20110120011026.GJ2232@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110120011026.GJ2232@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: werner <w.landgraf@ru.ru>, Borislav Petkov <bp@amd64.org>, Ilya Dryomov <idryomov@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 20, 2011 at 02:10:26AM +0100, Johannes Weiner wrote:
> Actually, I sent it half an hour before you ;-) But good to see that
> it fixes the problem.

I see, if I read your email before Ilya's PM it'd been
easier. Let's consider my patch an aked-by then ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
