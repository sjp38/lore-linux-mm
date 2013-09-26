Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id DA6396B0031
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 02:49:36 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so710524pbc.26
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 23:49:36 -0700 (PDT)
Message-ID: <5243D8FA.9090404@suse.cz>
Date: Thu, 26 Sep 2013 08:49:30 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [munlock] BUG: Bad page map in process killall5 pte:cf17e720
 pmd:05a22067
References: <20130926004028.GB9394@localhost>
In-Reply-To: <20130926004028.GB9394@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/26/2013 02:40 AM, Fengguang Wu wrote:
> Hi Vlastimil,
> 
> FYI, this bug seems still not fixed in linux-next 20130925.

Hi,

I sent (including you) a RFC patch and later reviewed patch about week
ago. I assumed you would test it, but I probably should make that
request explicit, sorry. Anyway it was added to -mm an hour before your
mail.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
