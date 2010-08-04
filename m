Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9AC8C62012A
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 04:38:13 -0400 (EDT)
Received: by iwn2 with SMTP id 2so6839036iwn.14
        for <linux-mm@kvack.org>; Wed, 04 Aug 2010 01:38:12 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 4 Aug 2010 16:38:12 +0800
Message-ID: <AANLkTi=1DxqLrqVbfRouOBRWg4RHFaHz438X7F1JWL6P@mail.gmail.com>
Subject: question about CONFIG_BASE_SMALL
From: Ryan Wang <openspace.wang@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: kernelnewbies@nl.linux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

      I noticed CONFIG_BASE_SMALL in different parts
of the kernel code, with ifdef/ifndef.
      I wonder what does CONFIG_BASE_SMALL mean?
And how can I configure it, e.g. through make menuconfig?

thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
