Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1BD6B0038
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 17:46:11 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so122032835pab.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 14:46:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id uq4si28407595pac.274.2016.08.15.14.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 14:46:10 -0700 (PDT)
Date: Mon, 15 Aug 2016 14:46:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 70/106] arch/x86/kernel/process.c:511:9: error:
 implicit declaration of function 'randomize_page'
Message-Id: <20160815144607.1a6c05709668b3ecd61e55da@linux-foundation.org>
In-Reply-To: <65DEA104-339F-4EB0-9E98-8959D28BA245@lakedaemon.net>
References: <201608120949.AtRXkB4G%fengguang.wu@intel.com>
	<65DEA104-339F-4EB0-9E98-8959D28BA245@lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 11 Aug 2016 21:31:15 -0400 Jason Cooper <jason@lakedaemon.net> wrote:

> Andrew, 
> 
> I think you have v1 and v2 of the randomize page patches in your stack. Could you drop v1 please?
> 

I have the v1 series and a series of deltas which turn that into v2.

I also see a v3 on the lists so I'm all confused.  Please triple-check
linux-next versus your latest version.

I can't reproduced this build error.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
