Subject: Re: [PATCH 0/12] Pass MAP_FIXED down to get_unmapped_area
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1176346589.29581.32.camel@roc-desktop>
References: <1176344427.242579.337989891532.qpush@grosgo>
	 <1176346589.29581.32.camel@roc-desktop>
Content-Type: text/plain
Date: Thu, 12 Apr 2007 12:56:19 +1000
Message-Id: <1176346579.8061.119.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bryan.wu@analog.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Is there any support consideration for nommu arch such as blackfin which
> is in the -mm tree now?
> 
> It is very kind of you to point out some idea about MAP_FIXED for
> Blackfin arch, I will do some help for this.

Right now, my understanding is that nommu archs just reject MAP_FIXED
outright... we might be able to be smarter, especially if we bring a
better infrastructure which I'm still thinking about.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
