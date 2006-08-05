Date: Fri, 4 Aug 2006 19:01:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Apply type enum zone_type
In-Reply-To: <200608050338.47642.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0608041900180.6160@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608041654380.5573@schroedinger.engr.sgi.com>
 <200608050338.47642.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Sat, 5 Aug 2006, Andi Kleen wrote:

> > We run into some troubles at some points with functions that need a
> > zone_type variable to become -1. Fix that up.
> 
> enums are not really type checked, so it seems somewhat pointless
> to do this change.

It helps to clarify what types of values can be expected from a variable.
We have that in various places.

> If you really wanted strict type checking you would need typedef struct
> and accessors.

Right. We definitely do not want that overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
