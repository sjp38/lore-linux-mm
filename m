Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id BBF096B0031
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 05:17:13 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so4296586pbb.34
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 02:17:13 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id ek3si8164645pbd.235.2014.02.08.02.17.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 08 Feb 2014 02:17:12 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id y10so4153904pdj.18
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 02:17:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131213070351.GD8845@lge.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1385974183-31423-6-git-send-email-iamjoonsoo.kim@lge.com>
	<00000142b3d18433-eacdc401-434f-42e1-8988-686bd15a3e20-000000@email.amazonses.com>
	<20131203021308.GE31168@lge.com>
	<20131213070351.GD8845@lge.com>
Date: Sat, 8 Feb 2014 12:17:11 +0200
Message-ID: <CAOJsxLHBuJ9t+5tHr=DxZK79FseWw2hGBeRewFc1prL6=m_hew@mail.gmail.com>
Subject: Re: [PATCH v3 5/5] slab: make more slab management structure off the slab
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 13, 2013 at 9:03 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> Hello, Pekka.
>
> Below is updated patch for 5/5 in this series.
> Now I get acks from Christoph to all patches in this series.
> So, could you merge this patchset? :)
> If you want to resend wholeset with proper ack, I will do it
> with pleasure.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
