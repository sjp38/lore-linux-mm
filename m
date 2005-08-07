Subject: Re: Getting rid of SHMMAX/SHMALL ?
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <Pine.LNX.4.61.0508041547500.4373@goblin.wat.veritas.com>
References: <20050804113941.GP8266@wotan.suse.de>
	 <Pine.LNX.4.61.0508041409540.3500@goblin.wat.veritas.com>
	 <20050804132338.GT8266@wotan.suse.de>
	 <20050804142040.GB22165@mea-ext.zmailer.org>
	 <Pine.LNX.4.61.0508041547500.4373@goblin.wat.veritas.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Sun, 07 Aug 2005 12:38:32 +0100
Message-Id: <1123414712.9464.26.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Matti Aarnio <matti.aarnio@zmailer.org>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Anton Blanchard <anton@samba.org>, cr@sap.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Iau, 2005-08-04 at 15:48 +0100, Hugh Dickins wrote:
> On Thu, 4 Aug 2005, Matti Aarnio wrote:
> > 
> > SHM resources are non-swappable, thus I would not by default
> > let user programs go and allocate very much SHM spaces at all.
> 
> No, SHM resources are swappable.

Large limits as oracle needs still allows any user to clog up the box
completely. 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
