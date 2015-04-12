Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BA6556B0038
	for <linux-mm@kvack.org>; Sun, 12 Apr 2015 03:20:33 -0400 (EDT)
Received: by pdea3 with SMTP id a3so71222740pde.3
        for <linux-mm@kvack.org>; Sun, 12 Apr 2015 00:20:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pc5si10238304pac.85.2015.04.12.00.20.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Apr 2015 00:20:33 -0700 (PDT)
Date: Sun, 12 Apr 2015 00:25:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: show free pages per each migrate type
Message-Id: <20150412002505.98eae258.akpm@linux-foundation.org>
In-Reply-To: <COL130-W1779F50C23B3E7EA23A707BAF80@phx.gbl>
References: <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>
	<20150409134701.5903cb5217f5742bbacc73da@linux-foundation.org>
	<COL130-W536B434DEADC19798C2A9FBAFA0@phx.gbl>
	<20150409212441.a64c3fe0.akpm@linux-foundation.org>
	<COL130-W1779F50C23B3E7EA23A707BAF80@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ZhangNeil <neilzhang1123@hotmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, 12 Apr 2015 07:17:11 +0000 ZhangNeil <neilzhang1123@hotmail.com> wrote:

> I calculate the__nr_free[][] again, it is an 6x11 array of 8 in the worst case, that is 528B, is it acceptable?

I don't think so.  This is hardly a critical change and that's a high cost.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
