Date: Wed, 6 Feb 2002 10:58:41 +0100
From: bert hubert <ahu@ds9a.nl>
Subject: Re: .Help with measuring working-set
Message-ID: <20020206105841.A32091@outpost.ds9a.nl>
References: <3C5F418C.6030808@netscape.com> <20020206100344.A28700@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020206100344.A28700@wotan.suse.de>; from ak@suse.de on Wed, Feb 06, 2002 at 09:04:30AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Suresh Duddi <dp@netscape.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2002 at 09:04:30AM +0000, Andi Kleen wrote:

> > Any pointers ? Are the metrics the best ones to measure and optimize ?
> 
> I guess you would prefer to know which pages are mapped at a given
> point. This would require some custom patching to add a trace facility
> for that. Shouldn't be that hard to implement, but I don't know of a 
> ready patch.

mincore(2) perhaps?

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
Netherlabs BV / Rent-a-Nerd.nl           - Nerd Available -
Linux Advanced Routing & Traffic Control: http://ds9a.nl/lartc
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
