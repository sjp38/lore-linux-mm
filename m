Date: Wed, 30 Mar 2005 14:40:49 +0100
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] Pageset Localization V2
Message-ID: <20050330134049.GA21986@parcelfarce.linux.theplanet.co.uk>
References: <Pine.LNX.4.58.0503292147200.32571@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0503292147200.32571@server.graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 29, 2005 at 09:51:08PM -0800, Christoph Lameter wrote:
> +	BUG_ON(process_zones(smp_processor_id()));

No.  Who told you this was a good idea?  This is the *worst* kind of
assert, calling a function with side-effects.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
