Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95FE8280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 05:40:14 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g12so11068886wrg.15
        for <linux-mm@kvack.org>; Sun, 21 May 2017 02:40:14 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.11])
        by mx.google.com with ESMTPS id l198si25478509wma.152.2017.05.21.02.40.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 02:40:13 -0700 (PDT)
Subject: Re: zswap: Delete an error message for a failed memory allocation in
 zswap_dstmem_prepare()
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
 <bae25b04-2ce2-7137-a71c-50d7b4f06431@users.sourceforge.net>
 <20170521084734.GB1456@katana>
From: SF Markus Elfring <elfring@users.sourceforge.net>
Message-ID: <7bd4b458-6f6e-416b-97a9-b1b3d0840144@users.sourceforge.net>
Date: Sun, 21 May 2017 11:40:06 +0200
MIME-Version: 1.0
In-Reply-To: <20170521084734.GB1456@katana>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wolfram Sang <wsa@the-dreams.de>, linux-mm@kvack.org
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

> Markus, can you please stop CCing me on every of those patches?

Yes, of course.


>> Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf

Did I interpret any information from your presentation slides in an
inappropriate way?


> And why do you create a patch for every occasion in the same file?

This can occasionally happen when I am more unsure about the change acceptance
for a specific place.


> Do you want to increase your patch count?

This can also happen as a side effect if such a source code search pattern
will point hundreds of places out for further software development considerations.
How would you prefer to clarify the remaining update candidates there?

Regards,
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
