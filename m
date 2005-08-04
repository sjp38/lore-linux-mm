Date: Thu, 4 Aug 2005 15:48:35 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Getting rid of SHMMAX/SHMALL ?
In-Reply-To: <20050804142040.GB22165@mea-ext.zmailer.org>
Message-ID: <Pine.LNX.4.61.0508041547500.4373@goblin.wat.veritas.com>
References: <20050804113941.GP8266@wotan.suse.de>
 <Pine.LNX.4.61.0508041409540.3500@goblin.wat.veritas.com>
 <20050804132338.GT8266@wotan.suse.de> <20050804142040.GB22165@mea-ext.zmailer.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matti Aarnio <matti.aarnio@zmailer.org>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Anton Blanchard <anton@samba.org>, cr@sap.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Aug 2005, Matti Aarnio wrote:
> 
> SHM resources are non-swappable, thus I would not by default
> let user programs go and allocate very much SHM spaces at all.

No, SHM resources are swappable.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
