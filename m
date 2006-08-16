Date: Wed, 16 Aug 2006 09:57:12 -0700
From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH2 1/1] network memory allocator.
Message-ID: <20060816095712.120b3171@localhost.localdomain>
In-Reply-To: <20060816075137.GA22397@2ka.mipt.ru>
References: <20060814110359.GA27704@2ka.mipt.ru>
	<20060816075137.GA22397@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

IMHO the network memory allocator is being a little too focused on one problem,
rather than looking at a general enhancement.

Have you looked into something like the talloc used by Samba (and others)?
	http://talloc.samba.org/
	http://samba.org/ftp/unpacked/samba4/source/lib/talloc/talloc_guide.txt

By having a context, we could do better resource tracking and also cleanup
would be easier on removal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
