Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5C90B6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 21:32:32 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id e65so92089064pfe.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 18:32:32 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id a84si349770pfj.116.2016.01.25.18.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 18:32:31 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id cy9so90481883pac.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 18:32:31 -0800 (PST)
Date: Mon, 25 Jan 2016 18:32:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] make apply_to_page_range() more robust.
In-Reply-To: <1453561543-14756-5-git-send-email-mika.penttila@nextfour.com>
Message-ID: <alpine.DEB.2.10.1601251832150.10939@chino.kir.corp.google.com>
References: <1453561543-14756-1-git-send-email-mika.penttila@nextfour.com> <1453561543-14756-5-git-send-email-mika.penttila@nextfour.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-60055957-1453775549=:10939"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Mika_Penttil=C3=A4?= <mika.penttila@nextfour.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-60055957-1453775549=:10939
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sat, 23 Jan 2016, mika.penttila@nextfour.com wrote:

> From: Mika PenttilA? <mika.penttila@nextfour.com>
> 
> 
> Now the arm/arm64 don't trigger this BUG_ON() any more,
> but WARN_ON() is here enough to catch buggy callers
> but still let potential other !size callers pass with warning.
> 
> Signed-off-by: Mika PenttilA? mika.penttila@nextfour.com

Acked-by: David Rientjes <rientjes@google.com>
--397176738-60055957-1453775549=:10939--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
