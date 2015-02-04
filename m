Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 96681900015
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 11:42:51 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id z6so1136142yhz.10
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 08:42:51 -0800 (PST)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id jz5si2610029qcb.10.2015.02.04.08.42.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 08:42:49 -0800 (PST)
Received: by mail-qg0-f46.google.com with SMTP id j5so2047007qga.5
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 08:42:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CABYiri9MEbEnZikqTU3d=w6rxtsgumH2gJ++Qzi1yZKGn6it+Q@mail.gmail.com>
References: <CABYiri9MEbEnZikqTU3d=w6rxtsgumH2gJ++Qzi1yZKGn6it+Q@mail.gmail.com>
From: Andrey Korolyov <andrey@xdel.ru>
Date: Wed, 4 Feb 2015 20:42:29 +0400
Message-ID: <CABYiri_0cDqDGMZCNGVfHwHJupyV6ox5-V1jaxteA-yX+T0_kA@mail.gmail.com>
Subject: Re: copy_huge_page: unable to handle kernel NULL pointer dereference
 at 0000000000000008
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, wanpeng.li@linux.intel.com, jipan.yang@gmail.com

Sorry for all the previous mess, my Claws-mailer went nuts for no reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
