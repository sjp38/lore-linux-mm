Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2D266B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 16:17:45 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id w3so2613828ywg.3
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 13:17:45 -0700 (PDT)
Received: from mail-yw0-x233.google.com (mail-yw0-x233.google.com. [2607:f8b0:4002:c05::233])
        by mx.google.com with ESMTPS id x32si2068438ybi.5.2016.10.04.13.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 13:17:29 -0700 (PDT)
Received: by mail-yw0-x233.google.com with SMTP id u124so49467554ywg.3
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 13:17:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <087b53e5-b23b-d3c2-6b8e-980bdcbf75c1@gmx.de>
References: <fcb653b9-cd9e-5cec-1036-4b4c9e1d3e7b@gmx.de> <20161004084136.GD17515@quack2.suse.cz>
 <90dfe18f-9fe7-819d-c410-cdd160644ab7@gmx.de> <2b7d6bd6-7d16-3c60-1b84-a172ba378402@gmx.de>
 <CABYiri-UUT6zVGyNENp-aBJDj6Oikodc5ZA27Gzq5-bVDqjZ4g@mail.gmail.com> <087b53e5-b23b-d3c2-6b8e-980bdcbf75c1@gmx.de>
From: Andrey Korolyov <andrey@xdel.ru>
Date: Tue, 4 Oct 2016 23:17:08 +0300
Message-ID: <CABYiri_3qS6XgT04hCeF1AMuxY6W0k7QVEO-N0ZodeJTdG=xsw@mail.gmail.com>
Subject: Re: Frequent ext4 oopses with 4.4.0 on Intel NUC6i3SYB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Bauer <dfnsonfsduifb@gmx.de>
Cc: Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, linux-mm@kvack.org

> I'm super puzzled right now :-(
>

There are three strawman` ideas out of head, down by a level of
naiveness increase:
- disk controller corrupts DMA chunks themselves, could be tested
against usb stick/sd card with same fs or by switching disk controller
to a legacy mode if possible, but cascading failure shown previously
should be rather unusual for this,
- SMP could be partially broken in such manner that it would cause
overlapped accesses under certain conditions, may be checked with
'nosmp',
- disk accesses and corresponding power spikes are causing partial
undervoltage condition somewhere where bits are relatively freely
flipping on paths without parity checking, though this could be
addressed only to an onboard power distributor, not to power source
itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
