Date: Wed, 7 Jun 2000 15:17:26 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
Message-ID: <20000607151726.L30951@redhat.com>
References: <Pine.LNX.4.21.0006050716160.31069-100000@duckman.distro.conectiva> <qww1z29ssbb.fsf@sap.com> <20000607143242.D30951@redhat.com> <qwwbt1dpomv.fsf@sap.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <qwwbt1dpomv.fsf@sap.com>; from cr@sap.com on Wed, Jun 07, 2000 at 04:11:20PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 04:11:20PM +0200, Christoph Rohland wrote:
> 
> But for persistence we now have the shm dentries (We will have at
> least. I am planning to reuse the ramfs directory handling for shm
> fs. This locks the dentries into the cache for persistence). 
> 
> Couldn't we use this to get the desired behaviour? 

No, the dentries make things neat for the VFS but they don't help
the VM at all.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
