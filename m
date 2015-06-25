From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv1 5/8] xen/balloon: rationalize memory hotplug stats
Date: Thu, 25 Jun 2015 20:38:36 +0200
Message-ID: <20150625183836.GM14050@olila.local.net-space.pl>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
 <1435252263-31952-6-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1435252263-31952-6-git-send-email-david.vrabel@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Thu, Jun 25, 2015 at 06:11:00PM +0100, David Vrabel wrote:
> The stats used for memory hotplug make no sense and are fiddled with
> in odd ways.  Remove them and introduce total_pages to track the total
> number of pages (both populated and unpopulated) including those within
> hotplugged regions (note that this includes not yet onlined pages).
>
> This will be useful when deciding whether additional memory needs to be
> hotplugged.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Nice optimization! I suppose that it is remnant from very early
version of memory hotplug. Probably after a few patch series
iterations hotplug_pages and balloon_hotplug lost their meaning
and I did not catch it. Additionally, as I can see there is not
any consumer for total_pages here. So, I think that we can go
further and remove this obfuscated code at all.

Daniel
