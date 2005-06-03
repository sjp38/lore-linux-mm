Received: by zproxy.gmail.com with SMTP id 13so837377nzn
        for <linux-mm@kvack.org>; Fri, 03 Jun 2005 13:19:35 -0700 (PDT)
Message-ID: <6934efce0506031319a2bfbaf@mail.gmail.com>
Date: Fri, 3 Jun 2005 13:19:34 -0700
From: Jared Hulbert <jaredeh@gmail.com>
Reply-To: Jared Hulbert <jaredeh@gmail.com>
Subject: Re: defrag memory
In-Reply-To: <1117141158.27082.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <6934efce0505261214345a609f@mail.gmail.com>
	 <1117141158.27082.22.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> There are a few efforts (external patches) to decrease fragmentation to
> allow for more ease in removing memory, or allocating larger physically
> contiguous areas, but nothing in mainline or -mm.

Can you list me some key words to google for?

> Is there a particular reason you're interested?

power.  I'd like to switch off sdram banks that aren't used.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
