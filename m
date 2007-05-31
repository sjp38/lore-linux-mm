Date: Wed, 30 May 2007 17:49:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
In-Reply-To: <a8e1da0705301735r5619f79axcb3ea6c7dd344efc@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0705301747370.4809@schroedinger.engr.sgi.com>
References: <20070531002047.702473071@sgi.com>  <20070531003012.302019683@sgi.com>
 <a8e1da0705301735r5619f79axcb3ea6c7dd344efc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: young dave <hidave.darkstar@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 May 2007, young dave wrote:

> Hi Christoph,
> 
> > Introduce CONFIG_STABLE to control checks only useful for development.
> 
> What about control checks only as SLUB_DEBUG is set?

Debug code is always included in all builds unless it is an embedded 
system. Debug code is kept out of the hot path.

Disabling SLUB_DEBUG should only be done for embedded systems. That is why 
the option is in CONFIG_EMBEDDED.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
