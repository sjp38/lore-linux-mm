Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B642E6B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 18:57:16 -0500 (EST)
Received: by rn-out-0910.google.com with SMTP id 56so2870832rnw.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2009 15:57:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090128235514.GB24924@barrios-desktop>
References: <20090128102841.GA24924@barrios-desktop>
	 <1233156832.8760.85.camel@lts-notebook>
	 <20090128235514.GB24924@barrios-desktop>
Date: Thu, 29 Jan 2009 08:57:15 +0900
Message-ID: <28c262360901281557r295f65e0i2aed4d4d14fdbf52@mail.gmail.com>
Subject: Re: [BUG] mlocked page counter mismatch
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I missed my test program.

#include <stdio.h>
#include <sys/mman.h>
int main()
{
        mlockall(MCL_CURRENT);
        // munlockall();
        return 0;
}


-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
