Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2121C6B01BA
	for <linux-mm@kvack.org>; Tue, 25 May 2010 11:44:09 -0400 (EDT)
Subject: Re: [PATCH] cache last free vmap_area to avoid restarting beginning
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20100525150038.GA3227@barrios-desktop>
References: <1271427056.7196.163.camel@localhost.localdomain>
	 <1271603649.2100.122.camel@barrios-desktop>
	 <1271681929.7196.175.camel@localhost.localdomain>
	 <h2g28c262361004190712v131bf7a3q2a82fd1168faeefe@mail.gmail.com>
	 <1272548602.7196.371.camel@localhost.localdomain>
	 <1272821394.2100.224.camel@barrios-desktop>
	 <1273063728.7196.385.camel@localhost.localdomain>
	 <20100505161632.GB5378@laptop> <1274277294.2532.54.camel@localhost>
	 <20100525084323.GG5087@laptop>  <20100525150038.GA3227@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 May 2010 16:48:44 +0100
Message-ID: <1274802524.11327.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 2010-05-26 at 00:00 +0900, Minchan Kim wrote:

> Anyway, I am looking forard to seeing Steven's experiment.
> If test has no problem, I will remake refactoring patch based on your patch. :)
> 
> Thanks, Nick.

I gather that it might be a couple of days before our tester can run the
tests as he is busy with something else at the moment. I'll get back to
you as soon as I can. Apologies for the delay in testing,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
